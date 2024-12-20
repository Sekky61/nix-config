# Nix Config

Welcome. I hope you get inspired here.
It can be hard to put together a NixOS config, it certainly was for me.
This is mainly because you can structure it however you want.

My config is based on [CirnOS](https://github.com/end-4/CirnOS) ([docs](https://end-4.github.io/dots-hyprland-wiki/en/i-i/02usage/)) and [erictossell's flake](https://github.com/erictossell/nixflakes), go and give them a star!

The configuration starts with definition of hosts (computers) in [`hosts/default.nix`](hosts/default.nix).
Each `nixosSystem` defines arguments like `username` and `hostname`, which are available in all subsequent *modules*.
Each [NixOS module](https://nixos.wiki/wiki/NixOS_modules) defines some [configuration options](https://search.nixos.org/options), like [packages](https://search.nixos.org/packages) to install, services to run, or files to include.
My modules are mixed with home-manager, which I use to manage files in home.

I also define some *services*, which allow me to easily host them.

## Jump table

- [Neovim config](modules/nvim/init.lua)
- [Hyprland config](modules/hyprland.nix)

## Usage

Run `./scripts/update` to update the system. The script has commands, see `./scripts/update help`.

### Installation

This flake includes my hardware configuration, so you would need to add your host in `hosts/`.

```bash
git clone https://github.com/Sekky61/nix-config && cd nix-config
IMPURITY_PATH=$(pwd) sudo --preserve-env=IMPURITY_PATH nixos-rebuild switch --flake .#michal --impure
```

## Secrets

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix).

Setup and common tasks:
- Create a `.sops.yaml` file etc.
- After adding a host, run `sops updatekeys secrets/secrets.yaml`
- Add a pubkey: `sops rotate --in-place --add-age age1xxxxxxx modules/sops/secrets.yaml`

## Development

### AGS notes

Press `Super + /` to open the list of keybindings.

[Very useful docs](https://aylur.github.io/ags-docs/). Also look at [GJS docs](https://gjs.guide/).

- class `corner-black` makes fake rounded screen
- class `corner` controls rounding of the top bar
- Media widget: left click to show detailed controls, middle click to play/pause, right click to next track
- To debug, I just kill the ags with `ags -q` and then launch it in a shell: `ags`
- HTTP requests like Gemini use `libsoup`.

### Notes 

Rpi's service for wlan: `systemctl status wpa_supplicant-wlan0.service`
To change wallpaper, run script using `Control+Super+T`.

## Features

<!-- Over time add some info about each chosen part of the system -->

### Greetd

Uses `tuigreet`, on login launches Hyprland.

### Hyprland

The window manager. Launches Chrome on startup. Uses Ags bar. See shortcuts with `Super+/`.

