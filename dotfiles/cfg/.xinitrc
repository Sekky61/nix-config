source ~/.bash_aliases

exec awesome

# exec numlockx

[ -f ~/.xprofile ] && . ~/.xprofile

# enable touchpad tap to click
# xinput set-prop "11" "libinput Tapping Enabled" 1

# enable acceleration on yoga laptop
xinput set-prop 12 "libinput Accel Speed" 0.15