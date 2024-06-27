#!/bin/bash
# Assumes $PWD dotfiles

apt-get install git -y

# todo download git-credential-manager

# todo setup git to use gpg key
# git config --global user.signingkey <key>

# sign by default
# git config --global commit.gpgsign true

# git commit with -S flag to sign commit