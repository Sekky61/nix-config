#!/bin/bash
# Assumes $PWD dotfiles

# Font
unzip resources/RobotoMono.zip -d tmp/tempfont
unzip resources/InconsolataGo.zip -d tmp/tempfont
mv tmp/tempfont/* /usr/local/share/fonts
fc-cache -f -v # Update font cache

# Starship
cargo install starship --locked
ln -sf ~/dotfiles/cfg/starship.toml ~/.config/starship.toml
