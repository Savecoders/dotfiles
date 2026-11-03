.pragma library

function monitors(info) {
    return (info || []).filter(m => m && m.name && m.width > 0 && m.height > 0 && m.scale > 0).map(m => ({
        name: m.name, width: m.width, height: m.height, scale: m.scale,
        transform: m.transform || 0, x: m.x || 0, y: m.y || 0,
        logicalWidth: Math.round((m.transform % 2 ? m.height : m.width) / m.scale),
        logicalHeight: Math.round((m.transform % 2 ? m.width : m.height) / m.scale)
    }));
}

function matches(a, b) {
    return a.length === b.length && a.every(m => b.some(n =>
        m.name === n.name && m.width === n.width && m.height === n.height
        && m.scale === n.scale && m.transform === n.transform && m.x === n.x && m.y === n.y));
}

function validation(draft) {
    for (let i = 0; i < draft.length; i++) {
        const a = draft[i];
        if (![a.x, a.y].every(v => Number.isInteger(v) && Math.abs(v) <= 100000))
            return "Enter integer coordinates between -100000 and 100000.";
        for (let j = i + 1; j < draft.length; j++) {
            const b = draft[j];
            if (a.x < b.x + b.logicalWidth && b.x < a.x + a.logicalWidth
                    && a.y < b.y + b.logicalHeight && b.y < a.y + a.logicalHeight)
                return "Displays " + a.name + " and " + b.name + " overlap. Move them apart before applying.";
        }
    }
    return "";
}

function observation(info) {
    return JSON.stringify((info || []).map(m => [m.name, m.width, m.height, m.scale,
        m.transform || 0, m.x || 0, m.y || 0, m.refreshRate || 0, m.serial || "",
        m.description || "", !!m.disabled, m.mirrorOf || "none"])
        .sort((a, b) => String(a[0]).localeCompare(String(b[0]))));
}

function overlapArea(a, b) {
    const width = Math.min(a.x + a.logicalWidth, b.x + b.logicalWidth) - Math.max(a.x, b.x);
    const height = Math.min(a.y + a.logicalHeight, b.y + b.logicalHeight) - Math.max(a.y, b.y);
    return Math.max(0, width) * Math.max(0, height);
}

function swap(draft, aName, bName) {
    const a = draft.find(m => m.name === aName);
    const b = draft.find(m => m.name === bName);
    if (!a || !b)
        return draft.map(m => Object.assign({}, m));
    return draft.map(m => {
        if (m.name === aName)
            return Object.assign({}, m, {x: b.x, y: b.y});
        if (m.name === bName)
            return Object.assign({}, m, {x: a.x, y: a.y});
        return Object.assign({}, m);
    });
}

function placement(draft, name, x, y, threshold) {
    const moving = draft.find(m => m.name === name);
    const target = snapped(draft, name, x, y, threshold);
    const xs = [target.x], ys = [target.y];
    draft.filter(m => m.name !== name).forEach(m => {
        xs.push(m.x - moving.logicalWidth, m.x + m.logicalWidth);
        ys.push(m.y - moving.logicalHeight, m.y + m.logicalHeight);
    });
    let best = {x: moving.x, y: moving.y}, distance = Infinity, travel = Infinity;
    xs.forEach(px => ys.forEach(py => {
        const candidate = draft.map(m => m.name === name ? Object.assign({}, m, {x: px, y: py}) : m);
        if (validation(candidate)) return;
        const d = (px - target.x) ** 2 + (py - target.y) ** 2;
        const t = (px - moving.x) ** 2 + (py - moving.y) ** 2;
        if (d < distance || (d === distance && t < travel)) {
            best = {x: px, y: py}; distance = d; travel = t;
        }
    }));
    return best;
}

function bounds(monitors) {
    if (!monitors.length)
        return {x: 0, y: 0, width: 1920, height: 1080};
    const x = Math.min.apply(null, monitors.map(m => m.x));
    const y = Math.min.apply(null, monitors.map(m => m.y));
    return {x: x, y: y,
        width: Math.max.apply(null, monitors.map(m => m.x + m.logicalWidth)) - x,
        height: Math.max.apply(null, monitors.map(m => m.y + m.logicalHeight)) - y};
}

function snapped(draft, name, x, y, threshold) {
    const moving = draft.find(m => m.name === name);
    let bestX = threshold, bestY = threshold;
    let result = {x: Math.round(x), y: Math.round(y)};
    draft.filter(m => m.name !== name).forEach(m => {
        [m.x, m.x + m.logicalWidth, m.x - moving.logicalWidth,
            m.x + m.logicalWidth - moving.logicalWidth].forEach(edge => {
            if (Math.abs(edge - x) < bestX) { bestX = Math.abs(edge - x); result.x = edge; }
        });
        [m.y, m.y + m.logicalHeight, m.y - moving.logicalHeight,
            m.y + m.logicalHeight - moving.logicalHeight].forEach(edge => {
            if (Math.abs(edge - y) < bestY) { bestY = Math.abs(edge - y); result.y = edge; }
        });
    });
    return result;
}
