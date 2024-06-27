local wibox = require("wibox")
local beautiful = require('beautiful')
local gears = require('gears')

local widget = {}

local ICON_DIR = os.getenv("HOME") .. '/.config/awesome/widgets/volume/icons/'

local bg_shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end
function widget.get_widget(widgets_args)
    local args = widgets_args or {}

    local font = args.font or beautiful.font
    local icon_dir = args.icon_dir or ICON_DIR

    return wibox.widget {
        {
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
                        spacing = 2,

                        {
                            {
                                id = "icon",
                                resize = false,
                                widget = wibox.widget.imagebox,
                            },
                            valign = 'center',
                            layout = wibox.container.place
                        },
                        {
                            id = 'txt',
                            font = font,
                            widget = wibox.widget.textbox
                        },
        
                    }
                },
            },
        },
        
        layout = wibox.layout.fixed.horizontal,
        set_volume_level = function(self, new_value)
            self:get_children_by_id('txt')[1]:set_text(new_value)
            local volume_icon_name
            if self.is_muted then
                volume_icon_name = 'audio-volume-muted-symbolic'
            else
                local new_value_num = tonumber(new_value)
                if (new_value_num >= 0 and new_value_num < 33) then
                    volume_icon_name="audio-volume-low-symbolic"
                elseif (new_value_num < 66) then
                    volume_icon_name="audio-volume-medium-symbolic"
                else
                    volume_icon_name="audio-volume-high-symbolic"
                end
            end
            self:get_children_by_id('icon')[1]:set_image(icon_dir .. volume_icon_name .. '.svg')
        end,
        mute = function(self)
            self.is_muted = true
            self:get_children_by_id('icon')[1]:set_image(icon_dir .. 'audio-volume-muted-symbolic.svg')
        end,
        unmute = function(self)
            self.is_muted = false
        end
    }

end


return widget