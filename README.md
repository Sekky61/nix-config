# CirnOS

Based (heavily) on [CirnOS](https://github.com/end-4/CirnOS), go and give it a star!

See [the docs](https://end-4.github.io/dots-hyprland-wiki/en/i-i/02usage/)

# Installation
## Installing the whole system
- Please be advised that this flake includes my hardware configuration
- So this configuration likely won't work on your device... idk
```bash
git clone https://github.com/end-4/CirnOS.git && cd CirnOS
IMPURITY_PATH=$(pwd) sudo --preserve-env=IMPURITY_PATH nixos-rebuild switch --flake . --impure
```

## TODO

- alacritty clone shortcut

