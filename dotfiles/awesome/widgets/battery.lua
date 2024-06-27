local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
require("status.battery")

local battery = wibox.widget {
    widget = wibox.widget.textbox
}

local status_icon = {
    {99, " ", " "},
    {90, " ", " "},
    {80, " ", " "},
    {70, " ", " "},
    {60, " ", " "},
    {50, " ", " "},
    {40, " ", " "},
    {30, " ", " "},
    {20, " ", " "},
    {10, " ", " "},
    { 0, " ", " "},
}

awesome.connect_signal("status::battery", function(capacity, charging)
    battery.font = beautiful.font
    local markup = capacity .. "%"

    for _, value in pairs(status_icon) do
        if capacity >= value[1] then
            if (charging == true) then
                markup = "<span foreground='#f8f8f2'>" .. value[3] .. "</span>" .. markup
            else
				if capacity <= 50 then
					markup = "<span foreground='#E3605F'>" .. value[2] .. "</span>" .. markup
				else
					markup = "<span foreground='#f8f8f2'>" .. value[2] .. "</span>" .. markup
				end
            end
            break
        end
    end

    battery.markup = markup
end)

local bg_shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end
local battery_bubble = {
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

                battery,
            }
        },
    },
}

return battery_bubble