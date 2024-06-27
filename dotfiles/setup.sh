#!/bin/bash

#
# The main script
#
# Assumes child scripts would kill program if something went wrong
#

# Check if root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# functions

function ask() {
  read -p "$1 (Y/n): " resp
  if [ -z "$resp" ]; then
      response_lc="y" # empty is Yes
  else
      response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
  fi

  [ "$response_lc" = "y" ]
}

function echo_success() {
	echo "[ OK ]"
}

# Installation starts here

echo "Actions will be logged in setup_log"
exec 1>>setup_log 2>>setup_log

echo "Updating and Upgrading"
apt-get update && apt-get upgrade -y

# Prepare tmp folder
echo "Preparing tmp folder"
mkdir -p tmp

# Ask which files should be sourced
echo "Do you want to install: "
for file in install/*; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    if ask "${filename}?"; then
      source "$file"
      echo_success
    fi
  fi
done

# Finish

function cleanup() {
  echo "Cleaning up..."
  rm -fr tmp
  echo "Script finished."
}

cleanup

#
# TODOs
#

# todo keyboard shortcuts for suspend, hotspot

# What else to do? https://www.youtube.com/watch?v=GrI5c9PXS5k
# allow partner repositories
# set DNS to 1.1.1.1 and 1.0.0.1

# czech layout in settings > region
# sudo setxkbmap -layout cz

# todo tool https://github.com/slimm609/checksec.sh/zipball/main

# todo alt+tab scroll fix: imwheel
# start automatically after startup
# look into ~/.imwheelrc (https://github.com/freeplane/freeplane/issues/134)

# todo krusader theme and first launch

# todo hotspot macro

# todo https://github.com/madler/pigz

# todo custom alias for hexdump, ...

# todo git credential helper
# sudo apt install libsecret-1-dev
# git config --global credential.helper libsecret
# check if configured correctly with: git credential-libsecret

# todo zoxide https://github.com/ajeetdsouza/zoxide
# cargo install zoxide --locked
# or
# apt install zoxide
# eval "$(zoxide init bash)" 

# todo fzf fuzzyfinder, used by zoxide
# sudo apt-get install fzf

# todo navi
# cargo install --locked navi
# todo some custom cheatsheets
# cheat to remove node_modules and build folders

# todo id3tool
# todo guake
# todo add i3lock-fancy to install script

# todo gnome-session-properties
# start guake

# todo zerotier
# curl -s https://install.zerotier.com | sudo bash

# todo xsel
