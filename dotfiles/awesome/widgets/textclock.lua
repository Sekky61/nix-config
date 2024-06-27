local wibox = require("wibox")

local textclock = {
    format = "%a %d %B - %H:%M",
    widget = wibox.widget.textclock
}

return textclock
