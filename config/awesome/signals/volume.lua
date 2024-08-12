-- volume signal adapted for PipeWire using pactl
-- credits to Javacafe01

local awful = require("awful")

local volume_old = -1
local muted_old = -1

local function emit_volume_info()
    -- Get volume and mute state of the currently active sink using pactl
    awful.spawn.easy_async_with_shell(
        "pactl get-sink-volume @DEFAULT_SINK@ | cut -s -d/ -f2,4; pactl get-sink-mute @DEFAULT_SINK@",
        function(stdout)
            local volume = stdout:match('(%d+)%% /')
            local muted = stdout:match('muted:(%s+)[yes]')
            local muted_int = muted and 1 or 0
            local volume_int = tonumber(volume)
            
            -- Only send signal if there was a change
            if volume_int ~= volume_old or muted_int ~= muted_old then
                awesome.emit_signal("signals::volume", volume_int, muted)
                volume_old = volume_int
                muted_old = muted_int
            end
        end
    )
end

-- Run once to initialize widgets
emit_volume_info()

-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink #\"
    "]]


-- Kill old pactl subscribe processes
awful.spawn.easy_async({ "pkill", "--full", "--uid", os.getenv("USER"), "^pactl subscribe" }, function()
    -- Run emit_volume_info() with each line printed
    awful.spawn.with_line_callback(volume_script, {
        stdout = function(line)
            emit_volume_info()
        end
    })
end)