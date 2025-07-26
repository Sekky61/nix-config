{
  pkgs,
  username,
  impurity,
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

      # LLM/AI
      opencode

      # Utilities
      graphite-cli # Graphite stacked-PRs helper
    ];

    programs = {
      vscode.enable = true;
      opencode = {
        enable = true;
        # Package is overwritten in overlay

        # Settings have permissions problems, probably need write?
        # settings = {
        #   # https://opencode.ai/docs/config
        #   instructions = ["{file:./4.1-Beast.chatmode.md}"];
        #   mcp = {
        #     mcp-deepwiki = {
        #       command = ["npx" "-y" "mcp-deepwiki@latest"];
        #       enabled = true;
        #       type = "local";
        #     };
        #     playwright = {
        #       command = [
        #         "npx"
        #         "@playwright/mcp@latest"
        #       ];
        #       enabled = true;
        #       type = "local";
        #     };
        #   };
        # };
      };

      java.enable = true;
    };

    xdg.configFile."opencode/4.1-Beast.chatmode.md".source = impurity.link ./prompts/4.1-Beast.chatmode.md;
  };

  # localhost HTTPS development certs
  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  ];

  environment.systemPackages = with pkgs; [
    gemini-cli # it did not work in home-manager, some collision with eslint
  ];
}
