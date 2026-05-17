-- See https://wiki.hypr.land/Configuring/Start/

local config_home = os.getenv("XDG_CONFIG_HOME")
if config_home == nil or config_home == "" then
  config_home = os.getenv("HOME") .. "/.config"
end

package.path = table.concat({
  config_home .. "/hypr/?.lua",
  config_home .. "/hypr/?/init.lua",
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
