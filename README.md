# Nix Config

Welcome. I hope you get inspired here.
It can be hard to put together a NixOS config, it certainly was for me.
This is mainly because you can structure it however you want.

My config is based on [CirnOS](https://github.com/end-4/CirnOS) ([docs](https://end-4.github.io/dots-hyprland-wiki/en/i-i/02usage/)), [erictossell's flake](https://github.com/erictossell/nixflakes) and [konradmalik's dotfiles](https://github.com/konradmalik/dotfiles/tree/main), go and give them a star!

The configuration starts with definition of hosts (computers) in [`hosts/default.nix`](hosts/default.nix).
Each `nixosSystem` defines arguments like `username` and `hostname`, which are available in all subsequent *modules*.
Each [NixOS module](https://nixos.wiki/wiki/NixOS_modules) defines some [configuration options](https://search.nixos.org/options), like [packages](https://search.nixos.org/packages) to install, services to run, or files to include.
My modules are mixed with home-manager, which I use to manage files in home.

I also define some *services*, which allow me to easily host them.

## Jump table

- [Neovim config](modules/nvim/init.lua)
- [Hyprland config](modules/hyprland/)

## Usage

Run `./scripts/update` to update the system.

### Installation

The flake includes my hardware configuration, so you would need to create your host in `hosts/`.

```bash
git clone https://github.com/Sekky61/nix-config && cd nix-config
sudo nixos-rebuild switch --flake ".#hostname"
```
(substitute your `hostname`)

## Secrets

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix).

There is one universal age key for development. It is backed up in password manager.

Adding host without importing keys:
- First run of `nixos-rebuild` should put ssh keys in `/etc/ssh/ssh_host_ed25519_key(.pub)`. These are from now on used for decrypting sops secrets
- The first run should fail (no keys yet)
- After the fail, derive new age pubkey with `scripts/age-pubkey`
- add this pubkey to `.sops.yaml`
- run `sops updatekeys modules/sops/secrets.yaml`. This may (?) require existing key to be present (like a dev key).

Adding host with imported keys:
- Before running `nixos-rebuild`, put the keys `/etc/ssh/ssh_host_ed25519_key(.pub)` in 
- You can verify that the pubkey is already in `.sops.yaml` by comparing output of `scripts/age-pubkey`.

Rotating a key:
```bash
sops rotate --in-place --add-age age1xxxxxxx modules/sops/secrets.yaml
```

First install notes:
I used to have passwords setup with sops, but it was horrible when you mess up.
Now passwords are not declarative, just set them once.
You may need to put a private age key in `~/.config/sops/age/keys.txt` to successfully work with sops.

## Raspberry PI, ISO and installers

Installing on new machine requires generating `hardware-configuration.nix` and adding it to the flake.
In other words, you need to get the machine running with Nix (not necessarily nixos as I understand it), generate the configuration. After that you can use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) or update via ssh.

### Get NixOS installed on machine

Build minimal ISO (x86) or rpi SD card image:
```bash
nix build .#minimal-iso
# or
nix build .#minimal-pi-sd-image
```

Flash it (possibly unpack first - `unzstd -d rpi.img.zst`):
```bash
sudo dd if=installer.iso of=/dev/sdX bs=4096 conv=fsync status=progress
```

Find IP of the installed device:
```bash
sudo nmap -p 22 192.168.0.0/24
```

Partition the drives as you wish, then You may need to get new `hardware-configuration` (not described here). Generate config:
```bash
sudo nixos-install --flake github:Sekky61/nix-config#nixpi --root /mnt --no-bootloader
```
or use the update script. This way you do not have to commit to try the install.
`--no-bootloader` is unverified.

## Features

<!-- Over time add some info about each chosen part of the system -->

### Greetd

Uses `tuigreet`, on login launches Hyprland.

### Hyprland

The window manager. See shortcuts with `Super+/`.
Launches Chrome on startup. Uses Ags/astal bar. 

### Theme

The wallpaper is set in `hyprpaper.nix`.
Theme colors can be derived form wallpaper, picked, or be based on a color.
See the `./scripts/theme`.
You must update the configuration for it to take effect.

### Impurity

Each host definition has its complement `hostname-impure`.
Impurity means that certain files line nvim config get linked to this repository instead of
nix store. This is useful for fast iterations on configs.

To use them, try `scripts/update --impure`.

### Options

The modules are gradually becoming configurable via `michal` namespace.
The other features are selectively imported by hosts as modules.

```nix
michal.programs # Programs that might be not desired everywhere
michal.services # Long running services like Home assistant
```

See `./scripts/list-custom-options` for more.

### Neovim

The `nvim` config (located [here](modules/nvim/init.lua)) contains many useful
plugins and keybinds with descriptions. The plugins get installed at launch, so
this is not a pure Nix solution.

### Terminals

Multiple terminals are configured.
Choose one of them to be the default one (works with keybinds).

### Backups

[Borg](https://borgbackup.readthedocs.io/en/stable/) ([module](modules/borg.nix)) is used with the cloud solution [BorgBase](https://www.borgbase.com/).
There is a daily backup with some weekly and monthly retention.

If you find yourself on a new computer, or just want to restore, here are the steps:

```bash
./scripts/mount-backups
sudo -s
cd mount/<whatever>
cp <whatever> <destination>
```
You may need to change permissions on the destination: `sudo chown -R michal:users Documents`.
Unmount: `sudo borg umount ./mount`.

## Development

### AGS notes

To get typescript types:
```bash
cd modules/gui-packages/ags/config
npm i
```

(after migrating to v2, some features are pending)

Press `Super + /` to open the list of keybindings.

[Very useful docs](https://aylur.github.io/ags/). Also look at [GJS docs](https://gjs.guide/).

- class `corner-black` makes fake rounded screen
- class `corner` controls rounding of the top bar
- Media widget: left click to show detailed controls, middle click to play/pause, right click to next track
- To debug, I just kill the ags with `ags quit` and then launch it in a shell: `ags run` (or with a `--directory` flag).
- Look up icons with [icon-browser](https://github.com/Aylur/icon-browser/tree/main)
- Use `ags inspect` as inspector

### Notes 

Rpi's service for wlan: `systemctl status wpa_supplicant-wlan0.service`
Take a look at [https://github.com/NotAShelf/nyx/tree/main](https://github.com/NotAShelf/nyx/tree/main), a great inspiration.
