#!/bin/bash
ROFI_TEXT="exit"
typeset -A menu
rofi_theme_path="$HOME/.config/awesome/theme/spotlight-dark.rasi"
menu=(
    ["lock"]="i3lock -i /home/majer/dotfiles/awesome/theme/untroll-wp.png"
    ["shutdown"]="shutdown -h 0"
    ["suspend"]="systemctl suspend"
)
launcher_options=(-dmenu -i -lines "${#menu[@]}" -p "${ROFI_TEXT}" -theme "${rofi_theme_path}" \
         "${ROFI_COLORS[@]}" "${ROFI_OPTIONS[@]}") 
launcher=(rofi "${launcher_options[@]}")
selection="$(printf '%s\n' "${!menu[@]}" | sort | "${launcher[@]}")"
if [[ -n $selection ]]
then
    exec ${menu[${selection}]}
fi