{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./direnv.nix
    ./debugger.nix
  ];

  # packages for development
  environment.systemPackages = with pkgs; [
    # langs
    nodejs_23
    gjs
    bun
    yarn
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
    code-cursor
    nixos-generators
    insomnia
    wireshark
    act # github actions locally
    mkcert
    dive # for exploring docker images layers

    # deps
    glib
  ];

  home-manager.users.${username} = _: {
    programs.vscode = {
      enable = true;
    };
  };

  # localhost https dev
  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  ];
}
