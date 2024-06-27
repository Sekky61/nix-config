#!/bin/bash
# Assumes $PWD dotfiles

apt-get install neovim -y

# link config dir
ln -sf ~/dotfiles/nvim ~/.config/nvim
