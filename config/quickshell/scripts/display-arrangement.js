#!/usr/bin/env node
'use strict';
const net = require('node:net');
const fs = require('node:fs/promises');
const { constants } = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const { createHash } = require('node:crypto');
const { execFile, spawn } = require('node:child_process');
const { promisify } = require('node:util');
const { Controller, AtomicStore } = require('../lib/display-arrangement.js');
const execute = promisify(execFile);

function decode(text) {
    const value = text.trim();
    if (!value.startsWith('DA1:')) throw new Error('Rule identity is unavailable. Reload the updated Hyprland configuration.');
    return value.slice(4) === 'ok' ? true : JSON.parse(value.slice(4));
}
class HyprlandAdapter {
    constructor(run = execute) { this.run = run; }
    async command(args) {
        try {
            const { stdout, stderr } = await this.run('hyprctl', args, { timeout: 3000, maxBuffer: 1024 * 1024 });
            if (stderr.trim()) throw new Error(stderr.trim());
            return stdout;
        } catch (error) {
            if (!Number.isInteger(error.code)) throw error;
            const failure = new Error(`Hyprland request failed (exit ${error.code}): ${(error.stderr || error.stdout || error.message).trim()}`);
            failure.exitCode = error.code;
            throw failure;
        }
    }
    async identity() {
        return decode(await this.command(['repl', 'return savior_display.identity()']));
    }
    async snapshot() { return JSON.parse(await this.command(['monitors', '-j'])); }
    async move(name, position, generation) {
        // Restrict strings before embedding them as Lua literals; no user-supplied Lua is accepted.
        if (![name, position, generation].every(v => typeof v === 'string' && /^[A-Za-z0-9_.: x-]+$/.test(v))) {
            throw new Error('Unsafe monitor identity or position. Reload the updated Hyprland configuration.');
        }
        const result = decode(await this.command(['repl', `return savior_display.move(${JSON.stringify(name)},${JSON.stringify(position)},${JSON.stringify(generation)})`]));
        if (result !== true) throw new Error('The compositor did not acknowledge the position change.');
    }
}
function locations(environment = process.env) {
    if (!environment.XDG_RUNTIME_DIR || !environment.HYPRLAND_INSTANCE_SIGNATURE) {
        throw new Error('A Hyprland session and XDG_RUNTIME_DIR are required.');
    }
    const session = createHash('sha256').update(environment.HYPRLAND_INSTANCE_SIGNATURE).digest('hex').slice(0, 20);
    return {
        socket: path.join(environment.XDG_RUNTIME_DIR, `savior-display-${session}.sock`),
        state: path.join(environment.XDG_STATE_HOME || path.join(os.homedir(), '.local/state'), 'savior/display-arrangement.json')
    };
}
function connect(socket, action, data) {
    return new Promise((resolve, reject) => {
        const client = net.createConnection(socket);
        let output = '';
        client.setTimeout(20000, () => client.destroy(new Error('Display controller request timed out.')));
        client.on('connect', () => client.end(JSON.stringify({ action, data }) + '\n'));
        client.on('data', chunk => {
            output += chunk;
            if (output.length > 1024 * 1024) client.destroy(new Error('Display controller response is too large.'));
        });
        client.on('error', reject);
        client.on('end', () => {
            try {
                const reply = JSON.parse(output);
                if (!reply.ok) throw Object.assign(new Error(reply.error), { exitCode: reply.exitCode || 1 });
                resolve(reply.result);
            } catch (error) { reject(error); }
        });
    });
}
async function lockSocket(socket) {
    const lock = await fs.open(`${socket}.lock`, constants.O_CREAT | constants.O_RDWR | constants.O_NOFOLLOW, 0o600);
    try {
        const stat = await lock.stat();
        if (!stat.isFile() || stat.uid !== process.getuid()) throw new Error('The display controller lock must be an owned regular file.');
        // flock shares this open file description; the daemon retains the lock after the child exits.
        await new Promise((resolve, reject) => {
            const child = spawn('flock', ['--nonblock', '3'], { stdio: ['ignore', 'ignore', 'ignore', lock.fd] });
            child.once('error', reject);
            child.once('exit', code => code === 0 ? resolve() : reject(new Error('Another display controller is starting or running.')));
        });
        return lock;
    } catch (error) { await lock.close(); throw error; }
}
async function removeStaleSocket(socket) {
    let stat;
    try { stat = await fs.lstat(socket); } catch (error) { if (error.code === 'ENOENT') return; throw error; }
    if (!stat.isSocket() || stat.uid !== process.getuid()) throw new Error('The display controller path is not an owned Unix socket.');
    await new Promise((resolve, reject) => {
        const client = net.createConnection(socket);
        client.setTimeout(500, () => { client.destroy(); reject(new Error('An existing socket could not be proven stale.')); });
        client.once('connect', () => { client.destroy(); reject(new Error('An existing live socket is using the display controller path.')); });
        client.once('error', error => error.code === 'ECONNREFUSED' || error.code === 'ENOENT' ? resolve() : reject(error));
    });
    let current;
    try { current = await fs.lstat(socket); } catch (error) { if (error.code === 'ENOENT') return; throw error; }
    if (current.ino !== stat.ino || current.dev !== stat.dev) throw new Error('The display controller socket changed during recovery. Retry the request.');
    await fs.unlink(socket);
}
async function serve(paths, adapter = new HyprlandAdapter(), clock = Date.now) {
    const runtime = await fs.stat(path.dirname(paths.socket));
    if (runtime.uid !== process.getuid() || (runtime.mode & 0o077)) throw new Error('XDG_RUNTIME_DIR must be private and owned by the current user.');
    const lock = await lockSocket(paths.socket);
    try { await removeStaleSocket(paths.socket); } catch (error) { await lock.close(); throw error; }
    const controller = new Controller(adapter, new AtomicStore(paths.state), clock);
    let watchdog;
    const server = net.createServer({ allowHalfOpen: true }, client => {
        let input = '';
        client.setTimeout(5000, () => client.destroy());
        client.on('error', () => {});
        client.on('data', chunk => {
            input += chunk;
            if (input.length > 65536) client.destroy();
        });
        client.on('end', async () => {
            try {
                const request = JSON.parse(input);
                if (request.action === 'shutdown') {
                    if ((await controller.request('status')).phase !== 'idle') throw new Error('Revert pending changes before stopping the controller.');
                    client.end(JSON.stringify({ ok: true, result: { phase: 'idle' } }));
                    clearInterval(watchdog);
                    server.close();
                    return;
                }
                const result = await controller.request(request.action, request.data);
                client.end(JSON.stringify({ ok: true, result }));
            } catch (error) { client.end(JSON.stringify({ ok: false, error: error.message, exitCode: error.exitCode || 1 })); }
        });
    });
    try {
        await new Promise((resolve, reject) => {
            server.once('error', reject);
            server.listen(paths.socket, resolve);
        });
        await fs.chmod(paths.socket, 0o600);
    } catch (error) { server.close(); await lock.close(); throw error; }
    server.once('close', () => { clearInterval(watchdog); lock.close().catch(() => {}); });
    let ticking = false;
    watchdog = setInterval(async () => {
        if (ticking) return;
        ticking = true;
        try { await controller.request('tick'); } catch (error) { console.error(error.message); }
        finally { ticking = false; }
    }, 250);
    return server;
}
async function request(action, data, paths = locations()) {
    try { return await connect(paths.socket, action, data); }
    catch (error) { if (error.code !== 'ENOENT' && error.code !== 'ECONNREFUSED') throw error; }
    const child = spawn(process.execPath, [__filename, 'serve'], { detached: true, stdio: 'ignore', env: process.env });
    child.unref();
    for (let attempt = 0; attempt < 40; attempt++) {
        await new Promise(resolve => setTimeout(resolve, 50));
        try { return await connect(paths.socket, action, data); }
        catch (error) { if (error.code !== 'ENOENT' && error.code !== 'ECONNREFUSED') throw error; }
    }
    throw new Error('Display controller could not start. Check Node.js, flock and the private runtime directory.');
}
async function main() {
    const action = process.argv[2];
    if (action === '--help' || !action) {
        console.log('Usage: node display-arrangement.js snapshot|status|apply|confirm|revert|replay|shutdown [JSON]\nApply accepts {snapshot,positions:[{name,x,y}]}; confirm/revert accept {token}. Confirmation expires after 15 seconds. State: $XDG_STATE_HOME/savior/display-arrangement.json (default ~/.local/state). Only verified exact Hyprland 0.56.2 rules are supported.');
        return;
    }
    if (action === 'serve') { await serve(locations()); return; }
    const result = await request(action, JSON.parse(process.argv[3] || '{}'));
    console.log(JSON.stringify(result));
}
if (require.main === module) main().catch(error => { console.error(error.message); process.exitCode = error.exitCode || 1; });
module.exports = { HyprlandAdapter, decode, locations, connect, serve, request };
