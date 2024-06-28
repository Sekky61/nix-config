-- note: resize floating window using mouse: super + right click

local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local translate = require("widgets.translate")

-- Useful function to dump a table
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

local vim_rule = { name = {"VIM", "vim", "Code", "/bin/bash"} }
-- todo: chrome shortcuts
-- change the rumes of the hotkey groups
for i, v in pairs(hotkeys_popup.widget.default_widget.group_rules ) do
    -- if the name contains vim, then change the names when to show
    if string.find(i, "VIM") then
        -- https://awesomewm.org/apidoc/libraries/gears.matcher.html
        v.rule_any = vim_rule
        -- naughty.notify({title=i, text = dump(v), max_width=600, timeout=50})
    end
end

local my_vim_keys = require("vim_keys") 

hotkeys_popup.widget.add_hotkeys(my_vim_keys)
hotkeys_popup.widget.add_group_rules("VIM: z", { rule_any=vim_rule })

local M = {}

-- Default modkey.
modkey = "Mod4"

rofi_theme_path="~/.config/awesome/theme/spotlight-dark.rasi"
function launcher()
    awful.util.spawn("rofi -modi drun -show drun -show-icons -dpi 150 -no-click-to-exit -theme " .. rofi_theme_path, false)
end

function exit_menu()
    -- with shell!
    awful.spawn.with_shell("~/.config/awesome/kill_rofi.sh")
end

kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { "us", "cz", } -- "ua"} -- ua add later
kbdcfg.current = 1  -- us is default
kbdcfg.switch = function ()
   kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
   os.execute(kbdcfg.cmd .. " " .. kbdcfg.layout[kbdcfg.current])
end

-- {{{ Key bindings
M.globalkeys = gears.table.join(
    awful.key({ modkey }, "s",     hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- open launcher
    awful.key({ modkey }, "space", launcher,
              {description = "open launcher", group = "launcher"}),
    -- open shutdown menu
    awful.key({ modkey }, "Escape", exit_menu,
              {description = "open exit menu", group = "launcher"}),
    -- terminal, Mod1 is Alt
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
	awful.key({ modkey,           }, "q", function () if client.focus == nil then return end client.focus:kill() end,
              {description = "close", group = "client"}),
	-- awful.key({ modkey }, "r",
	-- 	function ()
	-- 		local c = awful.client.restore()
	-- 		-- Focus restored client
	-- 		if c then
	-- 			c:emit_signal(
	-- 				"request::activate", "key.unminimize", {raise = true}
	-- 			)
	-- 		end
	-- 	end,
	-- { description = "restore minimized", group = "client" }),

    -- Awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    -- awful.key({ modkey, "Control" }, "q", awesome.quit,
    --           {description = "quit awesome", group = "awesome"}),

    -- Focus window
    awful.key({ modkey,           }, "j", function () awful.client.focus.byidx(1) end,
              {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1) end,
              {description = "focus previous by index", group = "client"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact(0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    -- turn on hotspot
    -- problem with path, must be absolute
    awful.key({ "Control", "Mod1"  }, "h",     function () awful.util.spawn('~/Documents/nix-config/dotfiles/workflows/hotspot') end,
              {description = "Turn on hotspot", group = "Misc"}),
    -- Swap window
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(-1) end,
              {description = "swap with previous client by index", group = "client"}),

    -- Next layout
    awful.key({ modkey,           }, "Tab", function () awful.layout.inc(1) end,
              {description = "select next", group = "layout"}),

    -- Toggle floating on window
    awful.key({ modkey,           }, "f", awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    -- media keys
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("playerctl play-pause") end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn("playerctl next") end),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("playerctl previous") end),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -D pulse sset Master '5%+'") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -D pulse sset Master '5%-'") end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer -D pulse sset Master '0%'") end),
    -- then in keyboard shortcuts put your shortcut for changing layout
    awful.key({ "Mod1" }, "Shift_L", function () kbdcfg.switch() end,
    {description = "Switch keyboard layout", group = "client"}),
    awful.key({ modkey }, "c", function() 
        translate.launch{api_key = '<api-key>', url = 'url'} 
    end, { description = "run translate prompt", group = "launcher" })    
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    M.globalkeys = gears.table.join(M.globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
        -- Toggle tag on focused client.
        -- awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        --           function ()
        --               if client.focus then
        --                   local tag = client.focus.screen.tags[i]
        --                   if tag then
        --                       client.focus:toggle_tag(tag)
        --                   end
        --               end
        --           end,
        --           {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

M.clientbuttons = gears.table.join(
    -- Mouse left button
    awful.button({}, 1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
        end
    ),
    -- Mouse middle button
    awful.button({}, 2,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
        end
    ),
    -- Mouse right button
    awful.button({}, 3,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
        end
    ),
    awful.button({modkey}, 1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            -- Enable floating if it's not already
            if not c.floating then
                c.floating_geometry = nil
                c.floating = true
            end
            c.fullscreen = false
            c.maximized = false
            c.maximized_horizontal = false
            c.maximized_vertical = false
            awful.mouse.client.move(c)
        end
    ),
    awful.button({modkey}, 3,
        function(c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            -- Enable floating if it's not already
            if not c.floating then
                c.floating_geometry = nil
                c.floating = true
            end
            c.fullscreen = false
            c.maximized = false
            c.maximized_horizontal = false
            c.maximized_vertical = false
            awful.mouse.client.resize(c)
        end
    )
)

return M
