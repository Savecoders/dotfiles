#!/usr/bin/env node
'use strict';
const net = require('node:net');
const fs = require('node:fs/promises');
const { constants } = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const { createHash, randomUUID } = require('node:crypto');
const { execFile, spawn } = require('node:child_process');
const { promisify } = require('node:util');
const { Controller, AtomicStore } = require('../lib/display-arrangement.js');
const execute = promisify(execFile);

const protocol = 'quickshell-position-only-v2';
const migration = 'Legacy display management is still active. Revert any preview, stop the old controller with its idle-only shutdown command, remove the config.display-arrangement import from your writable Hyprland entrypoint, then reload Hyprland and restart Quickshell. Existing Nix preserve-mode configurations need this manual merge; no configuration or saved layout has been migrated automatically.';
const capability = `assert(savior_display == nil, ${JSON.stringify(migration)}); local v = hl.version(); assert(type(v) == 'string' and (v == '0.56.2' or v == '0.57.0' or v:match('^Hyprland 0%.56%.2%s') or v:match('^Hyprland 0%.57%.0%s')), 'Display arrangement requires Hyprland 0.56.2 or 0.57.0'); assert(#hl.get_loaded_plugins() == 0, 'Disable Hyprland plugins before using display arrangement');`;
function decode(text) {
    if (text.trim() !== 'DA2:ok') throw new Error('Hyprland rejected the limited display adapter: ' + text.trim());
    return true;
}
class HyprlandAdapter {
    constructor(run = execute) {
        this.run = run;
        this.limited = true;
        this.epoch = randomUUID();
        this.observed = false;
        this.failure = '';
        this.nextReconnect = 0;
    }
    async start(environment = process.env) {
        const signature = environment.HYPRLAND_INSTANCE_SIGNATURE;
        if (!signature || !/^[A-Za-z0-9_.-]+$/.test(signature)) throw new Error('Invalid Hyprland session identity.');
        this.eventPath = path.join(environment.XDG_RUNTIME_DIR, 'hypr', signature, '.socket2.sock');
        await this.ensureObservation();
    }
    async ensureObservation() {
        if (this.observed && !this.failure) return;
        if (Date.now() < this.nextReconnect) throw new Error(this.failure || 'Waiting to reconnect Hyprland event observation.');
        this.nextReconnect = Date.now() + 1000;
        this.events?.destroy();
        const socket = net.createConnection(this.eventPath);
        this.events = socket;
        let lost = false;
        const invalidate = message => {
            if (this.events !== socket || lost) return;
            lost = true;
            this.failure = message;
            this.observed = false;
            this.epoch = randomUUID();
        };
        socket.setTimeout(1500, () => socket.destroy(new Error('Hyprland event connection timed out.')));
        let buffer = '';
        socket.on('data', chunk => {
            if (this.events !== socket || lost) return;
            buffer += chunk.toString();
            if (buffer.length > 1024 * 1024) { socket.destroy(new Error('Invalid Hyprland event stream.')); return; }
            let end;
            while ((end = buffer.indexOf('\n')) !== -1) {
                const line = buffer.slice(0, end);
                buffer = buffer.slice(end + 1);
                if (!/^[a-zA-Z0-9_]+>>[^\r\n]*$/.test(line)) {
                    socket.destroy(new Error('Malformed Hyprland event.'));
                    return;
                }
                const event = line.slice(0, line.indexOf('>>'));
                if (event === 'configreloaded' || event === 'monitoradded' || event === 'monitorremoved'
                    || event === 'monitoraddedv2' || event === 'monitorremovedv2') {
                    this.epoch = randomUUID();
                }
            }
        });
        socket.on('error', error => invalidate(error.message));
        socket.on('close', () => invalidate('Hyprland event observation ended. Reconnecting; unresolved rollback is retained.'));
        await new Promise((resolve, reject) => {
            socket.once('connect', resolve);
            socket.once('error', reject);
            socket.once('close', () => reject(new Error(this.failure || 'Hyprland event connection closed.')));
        });
        if (lost) throw new Error(this.failure);
        socket.setTimeout(0);
        this.failure = '';
        this.observed = true;
        // Events missed while disconnected cannot inherit the previous generation.
        this.epoch = randomUUID();
    }
    guard(generation = this.epoch) {
        if (!this.observed || this.failure) throw new Error(this.failure || 'Hyprland session/reload observation is unavailable.');
        if (generation !== this.epoch) throw new Error('Display session, reload or topology changed. Refresh before applying.');
    }
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
        const generation = this.epoch;
        this.guard(generation);
        decode(await this.command(['repl', `${capability} return 'DA2:ok'`]));
        this.guard(generation);
        return { epoch: generation, generation, positions: {} };
    }
    async snapshot({ allowMissing = false } = {}) {
        const generation = this.epoch;
        this.guard(generation);
        const monitors = JSON.parse(await this.command(['monitors', 'all', '-j']));
        this.guard(generation);
        if (!Array.isArray(monitors) || monitors.some(m => !m || !['eDP-1', 'HDMI-A-1'].includes(m.name))
            || new Set(monitors.map(m => m.name)).size !== monitors.length) {
            throw new Error('Unexpected or malformed outputs. Limited mode supports only eDP-1 and HDMI-A-1.');
        }
        const active = monitors.filter(m => !m.disabled);
        if ((!allowMissing && active.length !== 2)
            || active.some(m => m.width !== 1920 || m.height !== 1080 || m.scale !== 1 || m.transform !== 0
                || !Number.isFinite(m.refreshRate) || Math.abs(m.refreshRate - 60) > 1)) {
            throw new Error('Limited mode requires eDP-1 and HDMI-A-1 at 1920x1080 near 60 Hz, scale 1 and transform 0. Missing outputs are accepted only for pending rollback recovery.');
        }
        return active;
    }
    async prepareReplay(accept) {
        const generation = this.epoch;
        let previous = '';
        let stable = 0;
        // Repeated baseline samples reduce reload races; Hyprland exposes no quiescence proof.
        for (let attempt = 0; attempt < 30; attempt++) {
            await this.identity();
            const monitors = await this.snapshot();
            this.guard(generation);
            const baseline = accept(monitors);
            const value = JSON.stringify(monitors.map(({ name, serial, width, height, scale, transform, refreshRate, x, y }) =>
                ({ name, serial, width, height, scale, transform, refreshRate, x, y })).sort((a, b) => a.name.localeCompare(b.name)));
            stable = baseline && value === previous ? stable + 1 : baseline ? 1 : 0;
            if (stable >= 3) return;
            previous = value;
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        throw new Error('Neither the assumed numeric baseline nor the matching confirmed layout settled. Replay stopped; restore eDP-1 at 0x0 and HDMI-A-1 at 1920x0, disable other display managers, then reload Hyprland.');
    }
    async move(name, position, generation) {
        if (!['eDP-1', 'HDMI-A-1'].includes(name) || typeof position !== 'string' || !/^-?\d+x-?\d+$/.test(position)
            || !position.split('x').every(v => Number.isInteger(Number(v)) && Math.abs(Number(v)) <= 100000)) {
            throw new Error('Limited mode accepts only the current outputs and bounded numeric positions.');
        }
        this.guard(generation);
        // Tagged 0.56.2/0.57.0 seed other fields only when this selector matches exactly.
        decode(await this.command(['repl', `${capability} hl.monitor({output=${JSON.stringify(name)},position=${JSON.stringify(position)}}); return 'DA2:ok'`]));
        this.guard(generation);
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
    try { await adapter.start(); } catch (error) { adapter.events?.destroy(); await lock.close(); throw error; }
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
                if (request.action === 'capabilities') {
                    client.end(JSON.stringify({ ok: true, result: { protocol } }));
                    return;
                }
                if (request.action === 'shutdown') {
                    const status = await controller.request('shutdown');
                    client.end(JSON.stringify({ ok: true, result: { phase: status.phase } }));
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
    } catch (error) { server.close(); adapter.events.destroy(); await lock.close(); throw error; }
    server.once('close', () => { clearInterval(watchdog); adapter.events.destroy(); lock.close().catch(() => {}); });
    let ticking = false;
    watchdog = setInterval(async () => {
        if (ticking) return;
        ticking = true;
        try { await controller.request('tick'); } catch (error) { console.error(error.message); }
        finally { ticking = false; }
    }, 250);
    // Replay is controller-owned and runs even if Settings is never opened.
    controller.request('tick').catch(error => console.error(error.message));
    return server;
}
async function compatibleConnect(socket, action, data) {
    let result;
    try { result = await connect(socket, 'capabilities', {}); }
    catch (error) {
        if (error.code === 'ENOENT' || error.code === 'ECONNREFUSED') throw error;
        throw new Error(migration);
    }
    if (result.protocol !== protocol) throw new Error(migration);
    return connect(socket, action, data);
}
async function request(action, data, paths = locations()) {
    try { return await compatibleConnect(paths.socket, action, data); }
    catch (error) { if (error.code !== 'ENOENT' && error.code !== 'ECONNREFUSED') throw error; }
    const child = spawn(process.execPath, [__filename, 'serve'], { detached: true, stdio: 'ignore', env: process.env });
    child.unref();
    for (let attempt = 0; attempt < 40; attempt++) {
        await new Promise(resolve => setTimeout(resolve, 50));
        try { return await compatibleConnect(paths.socket, action, data); }
        catch (error) { if (error.code !== 'ENOENT' && error.code !== 'ECONNREFUSED') throw error; }
    }
    throw new Error('Display controller could not start. Check Node.js, flock and the private runtime directory.');
}
async function main() {
    const action = process.argv[2];
    if (action === '--help' || !action) {
        console.log('Usage: node display-arrangement.js snapshot|status|apply|confirm|revert|replay|shutdown [JSON]\nApply accepts {snapshot,positions:[{name,x,y}]}; confirm/revert accept {token}. Confirmation expires after 15 seconds while the controller runs. State: $XDG_STATE_HOME/savior/display-arrangement.json (default ~/.local/state). Limited mode: Hyprland 0.56.2/0.57.0, no plugins, exactly eDP-1 and HDMI-A-1 at 1920x1080 near 60 Hz/scale 1/transform 0, exact selectors and numeric rules assumed. Startup/reload accepts a stable matching confirmed layout without moving it, or the assumed baseline eDP-1=0x0, HDMI-A-1=1920x0 before replay. Do not use competing display managers or change monitor rules. Position-only updates rely on exact-rule seeding; ICC/settings preservation and rollback cannot be guaranteed with rule changes or competing managers. Replay waits for observed stable geometry, not proof of compositor quiescence. Stop the old idle controller using the old script before replacing it; remove the legacy bridge import, reload Hyprland, then restart Quickshell. Preserved Nix/live files require manual migration. Unresolved preview journals are retained in the running daemon; recovery reconnects event observation and restores matching surviving/returning outputs when their numeric state is recognized and collision-free. Ambiguous geometry blocks recovery and editing. Shutdown is refused while a preview or rollback remains pending; journals are not crash-durable.');
        return;
    }
    if (action === 'serve') { await serve(locations()); return; }
    const result = await request(action, JSON.parse(process.argv[3] || '{}'));
    console.log(JSON.stringify(result));
}
if (require.main === module) main().catch(error => { console.error(error.message); process.exitCode = error.exitCode || 1; });
module.exports = { HyprlandAdapter, decode, locations, connect, serve, request };
