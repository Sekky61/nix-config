---------------------------
-- Default awesome theme --
---------------------------

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local theme = {}
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "default")

theme.font          = "Cantarell Bold 10"

theme.debug_red     = "#FF0000"
theme.bg_normal     = "#30323DBF"
theme.bg_focus      = "#5C80BC" -- blue
theme.bg_accent     = "#E8C547" -- yellow
theme.bg_urgent     = "#E8C547"
theme.bg_occupied   = "#4D5061"
theme.bg_minimize   = "#4D5061"
theme.bg_systray    = "#4D5061"
theme.systray_icon_spacing = 5

theme.fg_normal     = "#f8f8f2"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#f8f8f2"
theme.fg_minimize   = "#f8f8f2"

-- Hotkeys help
theme.hotkeys_fg = "#f8f8f2" -- basic text color
theme.hotkeys_modifiers_fg = "#E8C547" -- modifiers text color

-- notification

-- theme.notification_opacity = 0.84
-- theme.notification_bg = "#3F3F3F"
-- theme.notification_fg = "#F0DFAF"
-- theme.notification_border_width = 0
-- theme.notification_border_color = theme.debug_red
-- theme.notification_margin = 20

theme.notify_font_color_1                   = green
theme.notify_font_color_2                   = dblue
theme.notify_font_color_3                   = black
theme.notify_font_color_4                   = white
theme.notify_font                           = theme.font
theme.notify_fg                             = theme.fg_normal
theme.notify_bg                             = theme.bg_normal
theme.notify_border                         = theme.border_focus

theme.taglist_shape_border_width = 2
theme.taglist_shape_border_color_focus = theme.bg_accent
theme.taglist_bg_empty = "#00000000"
theme.taglist_shape_border_color = theme.bg_occupied

theme.taglist_bg_normal = theme.bg_normal
theme.taglist_bg_focus = theme.bg_accent
theme.taglist_bg_occupied = theme.bg_occupied
theme.taglist_bg_urgent = theme.bg_urgent

theme.tasklist_bg_normal = "#00000000"
theme.tasklist_bg_focus = "#00000000"
theme.tasklist_bg_occupied = "#00000000"
theme.tasklist_bg_urgent = "#00000000"
theme.tasklist_disable_icon = true
theme.tasklist_plain_task_name = false

theme.gap_single_client = true
theme.useless_gap   = dpi(2)
theme.border_width  = 2
theme.border_normal = theme.bg_occupied
theme.border_focus  = theme.bg_accent
theme.border_marked = theme.bg_accent

theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

theme.wallpaper = "/home/majer/.config/awesome/theme/untroll-wp.png"
theme.icon_theme = nil

-- Generate Awesome icon:
local theme_assets = require("beautiful.theme_assets")
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

return theme
