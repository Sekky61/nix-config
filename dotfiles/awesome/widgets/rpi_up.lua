local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local command = require("status.rpi_up")

local icon = {
    widget = wibox.container.place,
    {
        widget = wibox.widget.imagebox,
        image = os.getenv("HOME") .. "/.config/awesome/theme/icons/pi.svg",
        forced_width = 15,
        resize = true,
    },
}

local bg_shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end

local rpi_up = wibox.widget {
    widget = wibox.widget.textbox,
    markup = "-"
}

local widget = wibox.widget {
    widget = wibox.container.margin,
    top = 4,
    bottom = 4,

    {
        widget = wibox.container.background,
        bg = "#44475a",
        shape = bg_shape,
        {
            widget = wibox.container.margin,
            left = 5,
            right = 5,

            {
                widget = wibox.container.place,
                layout = wibox.layout.fixed.horizontal,
                spacing = 5,

                icon,
                rpi_up
            }
        },
    },
}

--- Adds mouse controls to the widget:
--  - left click - retry connection
widget:connect_signal("button::press", function(_, _, _, button)
    if (button == 1) then
        awful.spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
            awful.spawn("notify-send \"Pi\" \"Check complete\"")
            update_widget(exitcode == 0)
        end)
    end
end)

-- Change color on hover. this is how to address children of a widget
widget:connect_signal('mouse::enter', function()
    widget.children[1].bg = beautiful.bg_focus
end)

widget:connect_signal('mouse::leave', function()
    widget.children[1].bg = "#44475a"  -- Set it back to the original color
end)

function update_widget(up)
    rpi_up.font = beautiful.font
    --
    local online = up and "Online" or "Offline"
    local markup = online
    rpi_up.markup = markup
end

awesome.connect_signal("status::rpi_up", update_widget)

return widget
