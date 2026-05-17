-- See https://wiki.hypr.land/Configuring/Start/

local config_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = config_path:match("(.*/)")

-- Hyprland does not add the config file directory to Lua's module search path.
-- Keep module lookup relative to the entrypoint, whether it is loaded from the
-- canonical hypr/config path, the compatibility hypr/hyprland.lua path, or the
-- resolved Nix store path.
package.path = table.concat({
  config_dir .. "?.lua",
  config_dir .. "?/init.lua",
  config_dir .. "config/?.lua",
  config_dir .. "config/?/init.lua",
  package.path,
}, ";")

require("hypr.settings")
require("generated.monitors")
require("hypr.rules")
require("generated.rules")
require("hypr.binds")
require("generated.keybinds")
require("generated.startup")
require("hypr.startup")
