#!/bin/env sh

export QT_QPA_PLATFORMTHEME="qt5ct"
export _JAVA_AWT_WM_NONREPARENTING=1

#set resolution and refresh rate
# if [ -x "$(command -v xrandr)" ]; then
#   xrandr -s 2560x1080 -r 100
# fi

#start notification daemon
if [ -x "$(command -v dunst)" ]; then
  dunst &
fi

#start polkit
/usr/lib/polkit-kde-authentication-agent-1 &

if [ -x "$(command -v nm-applet)" ]; then
  nm-applet &
fi

# start kdeconnect
if [ -x "$(command -v kdeconnect-indicator)" ]; then
  kdeconnect-indicator &
fi

# Enable transparency
if [ -x "$(command -v picom)" ]; then
  picom &
fi

# autorun if not already running

# source: https://wiki.archlinux.org/title/awesome#Autostart
run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

run google-chrome
run spotify
