{
  pkgs,
  username,
  ...
}:
{

  imports = [
    ./direnv.nix
    ./debugger.nix
    ./docker.nix
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

    python311Packages.pip

    # tools
    git
    ffmpeg
    vscode
    code-cursor
    nixos-generators
    insomnia
    wireshark
    act # github actions locally
    mkcert

    # deps
    glib
  ];

  # localhost https dev
  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  ];
}
