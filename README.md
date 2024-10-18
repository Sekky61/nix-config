# Nix Config

Based (heavily) on [CirnOS](https://github.com/end-4/CirnOS) and inspired by [erictossell's flake](https://github.com/erictossell/nixflakes), go and give it a star!

See [the docs](https://end-4.github.io/dots-hyprland-wiki/en/i-i/02usage/) for the original dotfiles.

Features on top of CirnOS:
- Ollama chat tab
Incomplete list of changes:
- bash
- alacritty
- neovim
- small utilities like zoxide

Usage: run `./scripts/update` to update the system.

## Installation

### Installing the whole system
- Please be advised that this flake includes my hardware configuration
- So this configuration likely won't work on your device... idk
```bash
git clone https://github.com/Sekky61/nix-config && cd nix-config
IMPURITY_PATH=$(pwd) sudo --preserve-env=IMPURITY_PATH nixos-rebuild switch --flake .#michal --impure
```

## Development and editing

### AGS notes

Press `Super + /` to open the list of keybindings.

[Very useful docs](https://aylur.github.io/ags-docs/). Also look at [GJS docs](https://gjs.guide/).

- class `corner-black` makes fake rounded screen
- class `corner` controls rounding of the top bar
- Media widget: left click to show detailed controls, middle click to play/pause, right click to next track
- To debug, I just kill the ags with `ags -q` and then launch it in a shell: `ags`
- HTTP requests like Gemini use `libsoup`.

### TODO

-

### Notes 

Rpi's service for wlan: `systemctl status wpa_supplicant-wlan0.service`
