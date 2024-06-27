#!/bin/bash
# Assumes $PWD dotfiles

set_custom_shortcut() {
    local name="$1"
    local binding="$2"
    local command="$3"
    local binding_number="$4"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$binding_number/ name "$name"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$binding_number/ command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$binding_number/ binding "$binding"
    
    # Add the new custom keybinding to the list of custom keybindings
    local list=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${list::-1}, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$binding_number/']"
}

# Key	Symbol
# Alt	<Alt>
# Ctrl	<Control> or <Primary> -- the latter is preferred, mac users
# Shift	<Shift>
# Super/Windows key	<Super>
# Caps Lock	<Caps_Lock>
# Num Lock	<Num_Lock>
# Scroll Lock	<Scroll_Lock>
#
# In addition to the modifier keys, you can also use regular keys, such as letters and numbers, in shortcut bindings. 
# For example, to create a shortcut that opens a new terminal window with the Ctrl+Alt+T key combination, 
# you would use the binding <Control><Alt>t.

# Set custom shortcuts
set_custom_shortcut "suspend" "<Primary><Alt>s" "systemctl suspend" 1001
set_custom_shortcut "hotspot" "<Primary><Alt>h" "nmcli connection up Hotspot" 1002
