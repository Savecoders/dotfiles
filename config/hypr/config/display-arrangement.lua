local original_monitor = hl.monitor
local positions = {}
local original_positions = {}
local rules = {}
local ambiguous = false
local revision = 0
local epoch = tostring({}) .. ':' .. tostring(os.time()) .. ':' .. tostring(os.clock())
local bridge = {}

local function quote(value)
    return '"' .. value:gsub('[%z\1-\31\\"]', function(character)
        return string.format('\\u%04x', string.byte(character))
    end) .. '"'
end

local function copy(value)
    if type(value) ~= 'table' then
        return value
    end
    local result = {}
    for key, item in pairs(value) do
        result[key] = copy(item)
    end
    return result
end

local function tracked_monitor(rule)
    revision = revision + 1
    if type(rule) ~= 'table' or type(rule.output) ~= 'string' then
        ambiguous = true
        local ok, result = pcall(original_monitor, rule)
        if not ok then
            error(result, 0)
        end
        return result
    end

    local effective = copy(rules[rule.output] or {})
    for key, value in pairs(rule) do
        effective[key] = copy(value)
    end

    local ok, result = pcall(original_monitor, effective)
    if not ok then
        ambiguous = true
        error(result, 0)
    end
    if not effective.output:match('^[%w_.%-]+$') then
        ambiguous = true
    elseif effective.position ~= nil then
        if original_positions[effective.output] == nil then
            original_positions[effective.output] = effective.position
        end
        positions[effective.output] = effective.position
    elseif positions[effective.output] == nil then
        ambiguous = true
    end
    rules[effective.output] = effective
    return result
end
hl.monitor = tracked_monitor

local function supported_version(version)
    return type(version) == 'string' and (version == '0.56.2' or version == '0.57.0'
        or version:match('^Hyprland 0%.56%.2%s') or version:match('^Hyprland 0%.57%.0%s'))
end

local function capability()
    assert(supported_version(hl.version()),
        'Display arrangement requires the verified Hyprland 0.56.2 or 0.57.0 API.')
    assert(hl.monitor == tracked_monitor, 'Monitor tracking was replaced. Reload the updated Hyprland configuration.')
    assert(not ambiguous, 'Rule identity is ambiguous. Use exact output selectors with explicit positions and reload Hyprland.')
    assert(#hl.get_loaded_plugins() == 0, 'Display arrangement does not support monitor-changing plugins. Disable plugins and reload Hyprland.')
end

function bridge.generation()
    capability()
    return epoch .. ':' .. revision
end

function bridge.identity()
    capability()
    local entries = {}
    for name, position in pairs(positions) do
        assert(type(position) == 'string', 'Monitor positions must be explicit strings. Update the rule and reload Hyprland.')
        table.insert(entries, quote(name) .. ':' .. quote(position))
    end
    return 'DA1:' .. '{"epoch":' .. quote(epoch) .. ',"generation":' .. quote(bridge.generation()) .. ',"positions":{' .. table.concat(entries, ',') .. '}}'
end

function bridge.move(name, position, generation)
    capability()
    assert(generation == bridge.generation(), 'Monitor rules changed. Reload Hyprland before trying again.')
    local rule = rules[name]
    assert(rule ~= nil, 'Unknown monitor rule. Add an exact output rule with an explicit position and reload Hyprland.')
    assert(type(position) == 'string' and (position:match('^%-?%d+x%-?%d+$') or position == original_positions[name]),
        'Only numeric positions or the original position semantics can be applied.')
    local effective = copy(rule)
    effective.position = position
    original_monitor(effective)
    rules[name] = effective
    positions[name] = position
    return 'DA1:ok'
end

savior_display = bridge

local function replay()
    local config = os.getenv('XDG_CONFIG_HOME') or (os.getenv('HOME') .. '/.config')
    local script = config .. '/quickshell/scripts/display-arrangement.js'
    local escaped = "'" .. script:gsub("'", "'\\''") .. "'"
    hl.exec_cmd('node ' .. escaped .. ' replay')
end
hl.on('config.reloaded', replay)
hl.on('hyprland.start', replay)
