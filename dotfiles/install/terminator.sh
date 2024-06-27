#!/bin/bash
# Assumes $PWD dotfiles

apt-get install terminator

# apply config (symlink)
ln -s ~/dotfiles/cfg/terminator_config ~/.config/terminator/config

# point to $HOME/.config/alacritty/alacritty.toml
ln -s ~/dotfiles/cfg/alacritty.toml ~/.config/alacritty/alacritty.toml

# TODO
# make terminator active shell (type number with)
echo "Select terminator as default emulator using: sudo update-alternatives --config x-terminal-emulator"

#sudo update-alternatives --config x-terminal-emulator


# Alacritty

# sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
# sudo update-alternatives --config x-terminal-emulator
