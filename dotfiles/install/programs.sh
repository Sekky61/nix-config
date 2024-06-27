#!/bin/bash
# Assumes $PWD dotfiles, cargo

apt-get install make clang curl gnome-tweaks npm thefuck \
python3-distutils preload exa krename kdiff3 krusader shutter -y

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Chrome
wget -P /tmp/ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install ./tmp/google-chrome-stable_current_amd64.deb

nvm install node

npm install -g tldr

# Mold
git clone https://github.com/rui314/mold.git tmp
cd tmp/mold
git checkout v1.4.0
make -j$(nproc) CXX=g++
make install
cd ../..

# Bat
cargo install bat

snap install insomnia
