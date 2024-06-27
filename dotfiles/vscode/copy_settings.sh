#!/usr/bin/env bash

# copy settings vscode --> cwd

cp ~/.config/Code/User/settings.json ~/.config/Code/User/keybindings.json .
code --list-extensions | cat >extensions_list.txt

echo "Done"
