#!/bin/bash
# Assumes $PWD dotfiles

apt-get install gtk2-engines-murrine gtk2-engines-pixbuf

# theme guide
# https://www.omgubuntu.co.uk/2017/03/make-ubuntu-look-like-mac-5-steps

unzip resources/Mojave-dark.zip -d tmp/Mojave-dark
mkdir -p ~/.themes
mv tmp/Mojave-dark ~/.themes/Mojave-dark
gsettings set org.gnome.desktop.interface gtk-theme "Mojave-dark"
gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true # top bar on both monitors

# icon set
# https://github.com/keeferrourke/la-capitaine-icon-theme/releases

# todo download icons instead of them being in repo

unzip resources/icons.zip -d tmp/icons
mkdir -p ~/.icons
mv tmp/icons/la-capitaine-icon-theme-0.6.2 ~/.icons/la-capitaine-icon-theme-0.6.2
