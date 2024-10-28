{
  pkgs,
  username,
  ...
}:
{

  imports = [
    ./direnv.nix
    ./debugger.nix
  ];

  # packages for development
  environment.systemPackages = with pkgs; [
    # langs
    nodejs
    gjs
    bun
    cargo
    go
    gcc
    typescript
    eslint
    lua
    zig
    gnumake
    cmake
    alejandra # nix formatter

    # tools
    git
    ffmpeg
    vscode
    nixos-generators
    insomnia
    wireshark

    # deps
    glib
  ];
}
