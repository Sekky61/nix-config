local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
require("status.memory")

local icon = {
    widget = wibox.container.place,
    {
        widget = wibox.widget.imagebox,
        image = os.getenv("HOME") .. "/.config/awesome/theme/icons/memory.svg",
        forced_width = 15,
        resize = true,
    },
}

local bg_shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end

local memory = wibox.widget {
    widget = wibox.widget.textbox
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

                icon,
                memory
            }
        },
    },
}

awesome.connect_signal("status::memory", function(usage, total)
    memory.font = beautiful.font
    local markup = usage .. " MiB" .. " / " .. total .. " MiB"
    memory.markup = markup
end)

return widget
