{
  pkgs,
  username,
  ...
}: {
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
    bat
    eza
    gh # github cli
    fd
    ripgrep
    fzf
    socat
    jq
    gojq
    ffmpeg
    vscode
    lazygit
    nixos-generators
    insomnia
    wireshark

    # deps
    glib

    # todo take a look at it
  ];
}
