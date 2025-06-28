{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./direnv.nix
    ./debugger.nix
    ./git.nix
  ];

  # Of course many of these tools could be project-scoped and not in
  # global scope, but this is convenient
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      # Languages - JS/TS
      nodejs_latest
      typescript
      eslint
      yarn
      gjs
      bun

      # Languages - Rest
      cargo
      go
      gcc
      lua
      zig
      gnumake
      cmake
      alejandra # nix formatter
      python311Packages.pip

      # CLI tools
      nixos-generators
      wireshark
      insomnia
      mkcert
      ffmpeg
      act # GitHub Actions runner
      dive # Docker image layer explorer
      glib # gsettings, gdbus

      # Editors
      zed-editor
      code-cursor

      # Utilities
      graphite-cli # Graphite stacked-PRs helper
    ];

    programs.vscode.enable = true;
  };

  # localhost HTTPS development certs
  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  ];

  environment.systemPackages = with pkgs; [
    gemini-cli # it did not work in home-manager, some collision with eslint
  ];
}
