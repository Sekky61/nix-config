local awful = require("awful")

local command = "bash -c rpi_running"
local interval = 30

awful.widget.watch(command, interval, function(_, stdout, _, _, exitcode)
    -- send on or off signal
    awesome.emit_signal("status::rpi_up", exitcode == 0)
end)

-- return the command for others to use
return command
