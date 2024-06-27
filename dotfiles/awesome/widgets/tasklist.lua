local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local tasklist = {}

local tasklist_buttons = gears.table.join()

function tasklist.get(s)
    local widget = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.focused,
        buttons = tasklist_buttons
    }

    return widget
end

return tasklist
