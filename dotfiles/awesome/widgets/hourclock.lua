local gears = require("gears")
local wibox = require("wibox")

local icon = {
    widget = wibox.container.place,
    {
        widget = wibox.widget.imagebox,
        image = os.getenv("HOME") .. "/.config/awesome/theme/icons/clock.svg",
        forced_width = 15,
        resize = true,
    },
}
local hour = {
    widget = wibox.widget.textclock,
    format = "%H:%M",
}
local bg_shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end
local hourclock = {
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
                hour,
            }
        },
    },
}

return hourclock
