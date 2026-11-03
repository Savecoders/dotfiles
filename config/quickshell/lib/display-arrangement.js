'use strict';
const fs = require('node:fs/promises');
const path = require('node:path');
const { randomUUID } = require('node:crypto');
const { isDeepStrictEqual } = require('node:util');

function geometry(monitors) {
    if (!Array.isArray(monitors) || !monitors.length) throw new Error('No active displays are available.');
    const names = new Set();
    return monitors.map(m => {
        if (!m || typeof m.name !== 'string' || !/^[A-Za-z0-9_.-]+$/.test(m.name) || names.has(m.name)
            || !Number.isFinite(m.width) || m.width <= 0 || !Number.isFinite(m.height) || m.height <= 0
            || !Number.isFinite(m.scale) || m.scale <= 0 || !Number.isInteger(m.transform) || m.transform < 0 || m.transform > 7
            || !Number.isInteger(m.x) || !Number.isInteger(m.y) || m.disabled || (m.mirrorOf && m.mirrorOf !== 'none')) {
            throw new Error('Unsupported display geometry. Disable mirroring and refresh the display configuration.');
        }
        names.add(m.name);
        return { name: m.name, serial: m.serial || '', description: m.description || '', width: m.width, height: m.height,
            scale: m.scale, transform: m.transform, x: m.x, y: m.y,
            logicalWidth: Math.round((m.transform % 2 ? m.height : m.width) / m.scale),
            logicalHeight: Math.round((m.transform % 2 ? m.width : m.height) / m.scale) };
    }).sort((a, b) => a.name.localeCompare(b.name));
}
function topology(monitors) {
    return monitors.map(({ x, y, ...m }) => m);
}
function same(a, b) { return JSON.stringify(a) === JSON.stringify(b); }
function positions(monitors, changes) {
    if (!Array.isArray(changes) || !changes.length) throw new Error('No position changes requested.');
    const result = structuredClone(monitors);
    const names = new Set();
    for (const change of changes) {
        const monitor = change && result.find(m => m.name === change.name);
        if (!monitor || names.has(change.name)) throw new Error(`Unknown or duplicate output: ${change && change.name}.`);
        if (![change.x, change.y].every(v => Number.isInteger(v) && Math.abs(v) <= 100000)) {
            throw new Error('Positions must use bounded integer coordinates.');
        }
        names.add(change.name);
        monitor.x = change.x;
        monitor.y = change.y;
    }
    for (let i = 0; i < result.length; i++) {
        for (const b of result.slice(i + 1)) {
            const a = result[i];
            if (a.x < b.x + b.logicalWidth && b.x < a.x + a.logicalWidth
                && a.y < b.y + b.logicalHeight && b.y < a.y + a.logicalHeight) {
                throw new Error(`Displays ${a.name} and ${b.name} overlap.`);
            }
        }
    }
    return result;
}

function movementPlan(monitors, target) {
    let current = structuredClone(monitors);
    const remaining = target.filter(m => {
        const old = current.find(o => o.name === m.name);
        return old.x !== m.x || old.y !== m.y;
    });
    const plan = [];
    while (remaining.length) {
        let index = remaining.findIndex(m => {
            try { positions(current, [m]); return true; } catch (_) { return false; }
        });
        let next;
        if (index >= 0) next = remaining.splice(index, 1)[0];
        else {
            const monitor = remaining[0];
            const occupied = [...current, ...target];
            const right = Math.max(...occupied.map(m => m.x + m.logicalWidth)) + 1;
            const left = Math.min(...occupied.map(m => m.x)) - monitor.logicalWidth - 1;
            const below = Math.max(...occupied.map(m => m.y + m.logicalHeight)) + 1;
            const above = Math.min(...occupied.map(m => m.y)) - monitor.logicalHeight - 1;
            next = [{ x: right, y: 0 }, { x: left, y: 0 }, { x: 0, y: below }, { x: 0, y: above }]
                .map(p => ({ ...monitor, ...p })).find(p => {
                    try { positions(current, [p]); positions(target, [p]); return true; } catch (_) { return false; }
                });
            if (!next) throw new Error('No bounded collision-free temporary placement is available.');
        }
        current = positions(current, [next]);
        plan.push({ name: next.name, x: next.x, y: next.y });
    }
    return plan;
}

class Controller {
    constructor(adapter, store, clock = Date.now, options = {}) {
        this.adapter = adapter;
        this.store = store;
        this.clock = clock;
        this.sleep = options.sleep || (milliseconds => new Promise(resolve => setTimeout(resolve, milliseconds)));
        this.settleTimeout = options.settleTimeout || 2000;
        this.pending = null;
        this.recovery = '';
        this.recoveryGeneration = '';
        this.queue = Promise.resolve();
        this.synchronizedEpoch = '';
        this.stopping = false;
    }
    request(action, data = {}) {
        const operation = this.queue.then(() => this.execute(action, data));
        this.queue = operation.catch(() => {});
        return operation;
    }
    status() {
        return { phase: this.recovery ? 'recovery' : this.pending ? 'confirming' : 'idle',
            token: this.pending?.token || '', deadline: this.pending?.deadline || 0, error: this.recovery };
    }
    async snapshot({ allowMissing = false } = {}) {
        const proof = await this.adapter.identity();
        const raw = await this.adapter.snapshot({ allowMissing });
        const monitors = allowMissing && raw.length === 0 ? [] : geometry(raw);
        if (this.adapter.limited) {
            this.adapter.guard(proof.generation);
            proof.positions = Object.fromEntries(monitors.map(m => [m.name, `${m.x}x${m.y}`]));
        }
        if (!proof || typeof proof.generation !== 'string' || !proof.positions
            || monitors.some(m => typeof proof.positions[m.name] !== 'string')) {
            throw new Error('Rule identity is unavailable. Reload the updated Hyprland configuration.');
        }
        if (monitors.some(m => !/^(?:-?\d+x-?\d+|auto(?:-(?:left|right|up|down))?)$/.test(proof.positions[m.name]))) {
            throw new Error('Unsupported original position semantics. Use numeric or automatic cardinal positions and reload Hyprland.');
        }
        return { monitors, proof };
    }
    async waitFor(expected, generation, { allowMissing = false, automatic = '' } = {}) {
        const attempts = Math.max(3, Math.ceil(this.settleTimeout / 50));
        const deadline = this.clock() + this.settleTimeout;
        let stable = 0;
        let previous = null;
        const automaticNames = Array.isArray(automatic) ? automatic : [automatic];
        for (let attempt = 0; attempt <= attempts; attempt++) {
            const actual = await this.snapshot({ allowMissing });
            if (actual.proof.generation !== generation) throw new Error('Display topology or rules changed during apply.');
            const comparable = allowMissing && !this.adapter.limited ? expected.filter(m => actual.monitors.some(a => a.name === m.name)) : expected;
            const observed = allowMissing && !this.adapter.limited ? actual.monitors.filter(m => comparable.some(e => e.name === m.name)) : actual.monitors;
            if (same(topology(comparable), topology(observed)) && comparable.every(m => {
                const monitor = observed.find(a => a.name === m.name);
                return automaticNames.includes(m.name) || (monitor.x === m.x && monitor.y === m.y);
            })) {
                stable = same(actual.monitors, previous) ? stable + 1 : 1;
                if (stable >= 3) return actual;
            } else stable = 0;
            previous = actual.monitors;
            if (this.clock() >= deadline) break;
            if (attempt < attempts) await this.sleep(Math.min(50, deadline - this.clock()));
        }
        throw new Error('The compositor did not apply the requested geometry.');
    }
    recordMove(monitor, current) {
        const expected = positions(current.monitors, [monitor]);
        this.pending.journal.push({ name: monitor.name, position: current.proof.positions[monitor.name], monitors: current.monitors, expected });
        this.pending.expected = expected;
        return expected;
    }
    async recoverLimited() {
        const pending = this.pending;
        if (!pending) return this.status();
        pending.recovering = true;
        pending.retryAt = this.clock() + 1000;
        this.recovery = 'Rollback pending. The journal is retained; reconnect the original displays and restore event observation. Editing and confirmation are blocked.';
        try {
            const current = await this.snapshot({ allowMissing: true });
            const generation = current.proof.generation;
            const original = pending.before.monitors;
            if (!current.monitors.length) throw new Error('Waiting for the original displays to return.');
            const states = [original, pending.expected || original,
                ...pending.journal.flatMap(entry => entry.expected ? [entry.monitors, entry.expected] : [entry.monitors])];
            for (const monitor of current.monitors) {
                const before = original.find(m => m.name === monitor.name);
                if (!before || !same(topology([before]), topology([monitor]))) {
                    throw new Error(`Display ${monitor.name} no longer matches the original identity/geometry.`);
                }
                const recognized = states.some(state => state.some(m => same(m, monitor)));
                // Numeric baseline readback is an accepted rule assumption, not rule identity proof.
                const baseline = generation !== pending.before.proof.generation && monitor.y === 0
                    && monitor.x === (monitor.name === 'eDP-1' ? 0 : 1920);
                if (!recognized && !baseline) throw new Error(`Ambiguous position for ${monitor.name}; no recovery moves were sent.`);
            }
            const target = positions(current.monitors, original.filter(m => current.monitors.some(a => a.name === m.name)));
            const plan = movementPlan(current.monitors, target);
            let expected = current.monitors;
            for (const monitor of plan) {
                const observed = await this.waitFor(expected, generation, { allowMissing: true });
                expected = this.recordMove(monitor, observed);
                await this.adapter.move(monitor.name, `${monitor.x}x${monitor.y}`, generation);
                await this.waitFor(expected, generation, { allowMissing: true });
            }
            const restored = await this.waitFor(target, generation, { allowMissing: true });
            const missing = original.filter(m => !restored.monitors.some(a => a.name === m.name));
            if (missing.length) throw new Error(`Surviving displays restored; waiting for ${missing.map(m => m.name).join(', ')}. Returning outputs must be reconciled before editing resumes.`);
            if (!same(restored.monitors, original)) throw new Error('Original geometry is not fully restored.');
            this.adapter.guard(generation);
            this.pending = null;
            this.recovery = '';
            this.synchronizedEpoch = generation;
        } catch (error) {
            this.recoveryGeneration = pending.before.proof.generation;
            this.recovery = `Rollback incomplete: ${error.message} Journal retained; leave the controller running. Resolve ambiguous state or restore matching displays/event observation. Confirmed state was not changed.`;
        }
        return this.status();
    }
    async rollback() {
        const pending = this.pending;
        if (!pending) return this.status();
        if (this.adapter.limited) {
            await this.recoverLimited();
            if (this.pending) throw new Error(this.recovery);
            return this.status();
        }
        const errors = [];
        let expected = pending.expected || pending.before.monitors;
        for (const entry of [...pending.journal].reverse()) {
            try {
                const current = await this.snapshot();
                if (current.proof.generation !== pending.before.proof.generation
                    || (!same(current.monitors, expected) && !same(current.monitors, entry.monitors))) {
                    throw new Error('External display change detected; inverse moves were not sent.');
                }
                await this.adapter.move(entry.name, entry.position, pending.before.proof.generation);
                await this.waitFor(entry.monitors, pending.before.proof.generation, {
                    allowMissing: !this.adapter.limited, automatic: entry.position.startsWith('auto') ? entry.name : ''
                });
                expected = entry.monitors;
            } catch (error) { errors.push(error.message); }
            // Continuing past a failed inverse move could collide with a monitor that did not move.
            if (errors.length) break;
        }
        this.pending = null;
        if (errors.length) {
            this.recoveryGeneration = pending.before.proof.generation;
            this.recovery = `Rollback incomplete: ${errors.join(' ')} Stop other display managers and restore the exact numeric rules, then reload Hyprland. Confirmed state was not changed.`;
            throw new Error(this.recovery);
        }
        return this.status();
    }
    async apply(before, changes, replay = false) {
        const target = positions(before.monitors, changes);
        const plan = movementPlan(before.monitors, target);
        if (!plan.length) throw new Error('No position changes requested.');
        this.pending = { token: randomUUID(), deadline: this.clock() + 15000, before, target, journal: [] };
        let expected = before.monitors;
        try {
            for (const monitor of plan) {
                if (this.clock() >= this.pending.deadline) throw new Error('The apply deadline expired.');
                const current = await this.waitFor(expected, before.proof.generation);
                expected = this.recordMove(monitor, current);
                await this.adapter.move(monitor.name, `${monitor.x}x${monitor.y}`, before.proof.generation);
                await this.waitFor(expected, before.proof.generation);
            }
            const actual = await this.waitFor(target, before.proof.generation);
            this.pending.deadline = this.clock() + 15000;
            if (replay) this.pending = null;
            return { ...this.status(), monitors: actual.monitors };
        } catch (error) {
            await this.rollback();
            throw new Error(`Apply failed: ${error.message} Rolled back.`);
        }
    }
    async reloadBaseline(current) {
        const automatic = [];
        const expected = current.monitors.map(monitor => {
            const match = /^(-?\d+)x(-?\d+)$/.exec(current.proof.positions[monitor.name]);
            if (match) return { ...monitor, x: Number(match[1]), y: Number(match[2]) };
            automatic.push(monitor.name);
            return monitor;
        });
        return this.waitFor(expected, current.proof.generation, { automatic });
    }
    savedTarget(saved, monitors) {
        if (saved.version !== 1 || !same(saved.topology, topology(monitors))
            || !Array.isArray(saved.positions) || saved.positions.length !== monitors.length) {
            throw new Error('Saved display topology does not match. Back up the saved layout and restore the matching outputs before replay.');
        }
        return positions(monitors, saved.positions);
    }
    async replaySaved(before = null, saved = undefined) {
        if (saved === undefined) saved = await this.store.read();
        if (!saved) return this.status();
        before = before || await this.snapshot();
        const target = this.savedTarget(saved, before.monitors);
        if (same(target, before.monitors)) return this.status();
        return this.apply(before, saved.positions, true);
    }
    async synchronizeLimited() {
        if (!this.adapter.limited || this.pending || this.synchronizedEpoch === this.adapter.epoch) return;
        const generation = this.adapter.epoch;
        this.synchronizedEpoch = generation;
        this.recovery = '';
        try {
            // A confirmed layout may already be active when only the daemon restarts.
            const saved = await this.store.read();
            await this.adapter.prepareReplay(raw => {
                const monitors = geometry(raw);
                const confirmed = saved && same(this.savedTarget(saved, monitors), monitors);
                const baseline = monitors.every(m => m.y === 0 && m.x === (m.name === 'eDP-1' ? 0 : 1920));
                return confirmed || baseline;
            });
            this.adapter.guard(generation);
            const before = await this.snapshot();
            this.adapter.guard(generation);
            const confirmed = saved && same(this.savedTarget(saved, before.monitors), before.monitors);
            const baseline = before.monitors.every(m => m.y === 0 && m.x === (m.name === 'eDP-1' ? 0 : 1920));
            if (!confirmed && !baseline) throw new Error('Display geometry changed after startup/reload sampling.');
            await this.replaySaved(before, saved);
        } catch (error) {
            this.recoveryGeneration = this.synchronizedEpoch;
            this.recovery = this.pending ? this.recovery
                : `Display replay stopped: ${error.message} No automatic migration was performed. Resolve the configuration and reload Hyprland, or restore event observation.`;
        }
    }
    async execute(action, data) {
        if (this.stopping) throw new Error('The display controller is stopping.');
        if (action === 'shutdown') {
            if (this.pending) throw new Error('Pending rollback is unresolved. Keep the controller running and reconnect the original displays/event observation.');
            this.stopping = true;
            return this.status();
        }
        const previousToken = this.pending?.token;
        if (this.adapter.limited) {
            try { await this.adapter.ensureObservation(); }
            catch (error) {
                if (this.pending) this.pending.recovering = true;
                this.recovery = `Event observation unavailable: ${error.message} Reconnecting; unresolved rollback is retained and editing/confirmation are blocked.`;
                if (action === 'status' || action === 'tick') return this.status();
                throw new Error(this.recovery);
            }
            if (this.pending && (this.pending.recovering || this.pending.before.proof.generation !== this.adapter.epoch)) {
                this.pending.recovering = true;
                if (this.clock() >= (this.pending.retryAt || 0)) await this.recoverLimited();
            }
        }
        await this.synchronizeLimited();
        if (previousToken && !this.pending && (action === 'confirm' || action === 'revert')) {
            throw new Error(this.recovery || 'Pending preview was recovered after a display transition. Review the restored layout before editing.');
        }
        if (action === 'status' || (action === 'tick' && this.recovery)) return this.status();
        if (this.recovery && action === 'replay' && !this.adapter.limited) {
            const current = await this.snapshot();
            if (current.proof.generation !== this.recoveryGeneration) this.recovery = '';
        }
        if (this.recovery) throw new Error(this.recovery);
        if (action === 'snapshot') return this.snapshot();
        if (this.pending && !this.adapter.limited) {
            const current = await this.snapshot();
            if (current.proof.epoch && this.pending.before.proof.epoch && current.proof.epoch !== this.pending.before.proof.epoch) {
                this.pending = null;
                const baseline = await this.reloadBaseline(current);
                const restored = await this.replaySaved(baseline);
                if (action === 'confirm' || action === 'revert') {
                    throw new Error('Display configuration reloaded. Preview was discarded; confirmed layout restored.');
                }
                if (action === 'tick' || action === 'replay') return restored;
            }
        }
        if (action === 'tick') {
            if (this.pending) {
                try {
                    const current = await this.snapshot();
                    if (this.clock() >= this.pending.deadline || !same(current.monitors, this.pending.target)
                        || current.proof.generation !== this.pending.before.proof.generation) return this.rollback();
                } catch (_) { return this.rollback(); }
            }
            return this.status();
        }
        if (action === 'confirm' || action === 'revert') {
            if (!this.pending) throw new Error('No display change is awaiting confirmation.');
            if (data.token !== this.pending.token) throw new Error('Confirmation token does not match.');
            if (action === 'revert') return this.rollback();
            if (this.clock() >= this.pending.deadline) {
                await this.rollback();
                throw new Error('Confirmation expired. Changes were reverted.');
            }
            try {
                const current = await this.snapshot();
                if (!same(current.monitors, this.pending.target) || current.proof.generation !== this.pending.before.proof.generation) {
                    throw new Error('Display topology or positions changed before confirmation.');
                }
                await this.store.write({ version: 1, topology: topology(current.monitors),
                    positions: current.monitors.map(({ name, x, y }) => ({ name, x, y })) });
            } catch (error) {
                await this.rollback();
                throw new Error(`Save failed: ${error.message} Rolled back.`);
            }
            this.pending = null;
            return this.status();
        }
        if (this.pending) throw new Error('A display change is awaiting confirmation.');
        if (action === 'apply') {
            const before = await this.snapshot();
            // Limited mode rejects drafts from a previous observed reload, even at identical coordinates.
            if (!data.snapshot || !isDeepStrictEqual(before.monitors, data.snapshot.monitors)
                || (this.adapter.limited && before.proof.generation !== data.snapshot.proof?.generation))
                throw new Error('Display topology or positions changed. Refresh the draft.');
            return this.apply(before, data.positions);
        }
        if (action === 'replay') return this.replaySaved();
        throw new Error('Unknown display arrangement action.');
    }
}

class AtomicStore {
    constructor(file) { this.file = file; }
    async read() {
        try {
            const stat = await fs.lstat(this.file);
            if (!stat.isFile() || stat.isSymbolicLink()) throw new Error('Invalid state file.');
            const value = JSON.parse(await fs.readFile(this.file, 'utf8'));
            if (!value || value.version !== 1 || !Array.isArray(value.positions)) throw new Error('Invalid state schema.');
            return value;
        } catch (error) {
            if (error.code === 'ENOENT') return null;
            throw new Error('Existing display state is invalid. Back it up before replacing it.');
        }
    }
    async write(value) {
        await this.read();
        await fs.mkdir(path.dirname(this.file), { recursive: true, mode: 0o700 });
        const temporary = `${this.file}.${randomUUID()}.tmp`;
        try {
            const handle = await fs.open(temporary, 'wx', 0o600);
            try { await handle.writeFile(JSON.stringify(value) + '\n'); await handle.sync(); }
            finally { await handle.close(); }
            await fs.rename(temporary, this.file);
            // Rename is the commit point; a later durability failure must not report a rejected save.
            try {
                const directory = await fs.open(path.dirname(this.file), 'r');
                try { await directory.sync(); } finally { await directory.close(); }
            } catch (_) {}
        } finally { await fs.unlink(temporary).catch(error => { if (error.code !== 'ENOENT') throw error; }); }
    }
}
module.exports = { Controller, AtomicStore };
