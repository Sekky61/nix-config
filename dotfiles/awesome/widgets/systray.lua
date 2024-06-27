local gears = require("gears")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local bg_shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end
local systray = {
    widget = wibox.container.margin,
    top = dpi(2),
    bottom = dpi(2),
    wibox.widget.systray(),
}

local widget = {
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

                systray,
            }
        },
    },
}

return widget
