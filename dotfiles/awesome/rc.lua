-- Original config by dmun: https://github.com/dmun/awesome

-- docs: https://awesomewm.org/apidoc

naughty = require('naughty')  -- if not yet loaded

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

require("awful.hotkeys_popup.keys")

-- Theme handling library
local beautiful = require("beautiful")
-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
local theme_path = string.format("~/.config/awesome/theme/theme.lua")
beautiful.init(theme_path)

-- Widget and layout library
local wibox = require("wibox")

-- Notification library
local menubar = require("menubar")

local wibar = require("widgets.wibar")
local json = require("util.json")
local keys = require("keys")

-- Notify with dunst
function notify(title, description)
    awful.spawn("notify-send \"" .. title .. "\" \"" .. description .."\"")
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    awful.spawn("notify-send \"Oops, there were errors during startup!\" \"" .. awesome.startup_errors .."\"")
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        awful.spawn("notify-send \"Oops, an error happened!\" \"" .. tostring(err) .."\"")

        in_error = false
    end)
end
-- }}}

-- Get the system locale and apply it to awesome
os.setlocale(os.getenv("LANG"))

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
current_tag = nil

-- Layouts.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
}
-- }}}

-- {{{ Menu
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- The tags 1 and 2 use max, tag 3+ use tiles
local layouts = {
    awful.layout.layouts[2],
    awful.layout.layouts[2],
    awful.layout.layouts[1],
    awful.layout.layouts[1],
    awful.layout.layouts[1],
}

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5" }, s, layouts)
    -- Get the current tag in case it's not defined
    current_tag = s.selected_tag
    s.wibar = wibar.get(s)
end)

root.keys(keys.globalkeys)
awful.rules.rules = require("rules")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Update gaps of this client
    if current_tag and not c.floating then
        update_client_gaps(c)
    end
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("property::maximized", function(c)
    -- Prevent client to be maximized
    if not c.maximized then return end
    c.maximized = false
end)

client.connect_signal("property::minimized", function(c)
    -- Prevent client to be minimized
    if not c.minimized then return end
    c.minimized = false
end)

client.connect_signal("property::fullscreen", function(c)
    -- Fixes fullscreen not being entirely fullscreen
    if c.fullscreen then
        gears.timer.delayed_call(function()
            if c.valid then
                c:geometry(c.screen.geometry)
            end
        end)
    end
end)

client.connect_signal("property::floating", function(c)
    if c.fullscreen then return end
    if c.floating then
        c.ontop = true
    else
        c.ontop = false
    end
    -- Update borders of this client
    if current_tag then
        update_client_gaps(c)
    end
end)

tag.connect_signal("property::layout", function(t)
    -- Update clients gaps and borders when the layout changes
    update_clients_gaps(t)
end)

tag.connect_signal("property::selected", function(t)
    current_tag = t
    -- Update clients gaps and borders when changed tag
    update_clients_gaps(t)
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus c:raise() end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

function update_client_gaps(c)
    if c == nil then return end
    is_max = current_tag.layout.name == "max"
    beautiful.gap_single_client = not is_max
    border_width = beautiful.border_width

    -- Define width to zero if it's not floating and is in the max layout
    if not c.floating and is_max then
        border_width = 0
    end

    -- Set borders width for this client if it's not fullscreen or maximized
    if not c.fullscreen or c.maximized then
        c.border_width = border_width
    end
end

function update_clients_gaps(t)
    if t == nil then return end
    for _, c in pairs(t.screen.clients) do
        update_client_gaps(c)
    end
end

--- Autostart
awful.spawn.with_shell("~/.config/awesome/autostart.sh")

awful.spawn("notify-send \"AwesomeWM\" \"Welcome back, " .. os.getenv("USER") .. "\"")

-- autostart windows

function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    -- launches if not running
    if not arg_string then 
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end

-- run_once("google-chrome","startup", nil, 2)

-- Run garbage collector regularly to prevent memory leaks
gears.timer {
    timeout = 30,
    autostart = true,
    callback = function() collectgarbage() end
}
