#!/bin/bash
# Assumes $PWD dotfiles

mv ~/.bashrc ~/.bashrc_old # Old .bashrc
mkdir -p ~/.ssh

# symlink .bashrc and others to dotfiles
ln -sf ~/dotfiles/cfg/.bashrc ~/.bashrc
ln -sf ~/dotfiles/cfg/.bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/cfg/.profile ~/.profile
ln -sf ~/dotfiles/cfg/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/cfg/.gdbinit ~/.gdbinit
ln -sf ~/dotfiles/cfg/.tldrrc ~/.tldrrc
ln -sf ~/dotfiles/cfg/.xinitrc ~/.xinitrc
ln -sf ~/dotfiles/cfg/.xprofile ~/.xprofile

ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua

# case insensitive tab completion
echo 'set completion-ignore-case On' >> /etc/inputrc
