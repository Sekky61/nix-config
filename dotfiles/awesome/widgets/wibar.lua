local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
naughty = require('naughty')
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local hotkeys_popup = require("awful.hotkeys_popup")
local dpi = xresources.apply_dpi

-- local widget_padding = 8
local wibar_height = 20

-- notification style
-- prevent the icon size from being too big
naughty.config.defaults.icon_size = 100
naughty.config.defaults.ontop = true
naughty.config.defaults.timeout = 10
naughty.config.defaults.hover_timeout = 300
naughty.config.defaults.title = 'System Notification Title'
naughty.config.defaults.margin = dpi(16)
naughty.config.defaults.border_width = 0
naughty.config.defaults.position = 'top_right'
naughty.config.defaults.shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(6))
end

-- Widget imports
local mytaglist = require("widgets.taglist")
-- local mytasklist = require("widgets.tasklist")
local mysystray = require("widgets.systray")
local mymemory = require("widgets.memory")
local myrpi = require("widgets.rpi_up")
local myhourclock = require("widgets.hourclock")
local mydateclock = require("widgets.dateclock")
local spotify_widget = require("widgets.spotify.spotify")
local battery = require("widgets.battery")
local volume_widget = require('widgets.volume.volume')

local wibar = {}

terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end },
}


local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }
local has_fdo, freedesktop = pcall(require, "freedesktop")
if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  -- { "Debian", debian.menu.Debian_menu.Debian }, -- not working in nixos
                  menu_terminal,
                }
    })
end

banana_path = os.getenv("HOME") .. "/.config/awesome/theme/icons/banana.svg"
mylauncher = awful.widget.launcher({ image = banana_path,
                                     menu = mymainmenu })

local bg_shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end
local menubox = {
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

                mylauncher,
                date,
            }
        },
    },
}

function wibar.get(s)
    s.mypromptbox = awful.widget.prompt()
    local mywibox = awful.wibar({
        position = "top",
        screen = s,
        height = dpi(wibar_height)
    })

    local taglist = mytaglist.get(s)

    -- Add widgets to the wibox
    mywibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",

        { -- Left widgets
            widget = wibox.container.margin,
            left = 5,
            {
                widget = wibox.container.place,
                layout = wibox.layout.fixed.horizontal,
                spacing = 5,
                
                -- launcher,
                menubox,
                mydateclock,
                myhourclock,
                battery,
                volume_widget(),
                -- the Run: prompt
                s.mypromptbox,
            },
        },
        { -- Middle widgets
            widget = wibox.container.margin,
            -- left = 5,
            -- right = 5,
            top = 8,
            bottom = 8,
            taglist
        },
        { -- Right widgets
            widget = wibox.container.place,
            h_align = "right",
            {
                widget = wibox.container.margin,
                right = 5,
                {
                    widget = wibox.container.place,
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 5,
                    spotify_widget(),
                    mymemory,
                    myrpi,
                    mysystray,
                }
            }
        }
    }

    return mywibox
end

return wibar
