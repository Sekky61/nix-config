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
      tokei # count loc

      # Editors
      code-cursor

      # LLM/AI
      opencode
      lmstudio

      # Utilities
      graphite-cli # Graphite stacked-PRs helper
    ];

    programs = {
      vscode = {
        enable = true;
        # profiles are mutually exclusive with manual installation of extensions
      };

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

      zed-editor = {
        enable = true;
        extensions = ["angular" "nix" "biome" "lua"];

        userSettings = {
          theme = "Ayu Dark";

          languages = {
            Lua = {
              tab_size = 2;
              formatter = "language_server";
              format_on_save = "on";
            };

            Nix = {
              language_servers = ["nil"];
              formatter.external = {
                command = "nixpkgs-fmt";
                arguments = [];
              };
              format_on_save = "on";
            };
          };

          auto_indent_on_paste = true;
          auto_signature_help = true;
          hover_popover_enabled = true;
          show_completion_documentation = true;
          show_completions_on_input = true;
          show_edit_predictions = true;
          show_wrap_guides = true;
          use_autoclose = true;
          use_auto_surround = true;
          vim_mode = true;

          gutter = {
            breakpoints = true;
            code_actions = true;
            folds = true;
            line_numbers = true;
            runnables = true;
          };

          indent_guides = {
            active_line_width = 1;
            background_coloring = "disabled";
            coloring = "indent_aware";
            enabled = true;
            line_width = 1;
          };

          formatter = {
            language_server.name = "biome";
          };

          code_actions_on_format = {
            "source.fixAll.biome" = true;
            "source.organizeImports.biome" = true;
          };

          inlay_hints.enabled = false;

          telemetry = {
            diagnostics = false;
            metrics = false;
          };
        };

        userKeymaps = [
          {
            context = "Editor && vim_mode == normal || vim_mode == visual";
            bindings = {
              "space c" = "editor::ToggleComments";
            };
          }
        ];
      };

      java.enable = true;
    };

    xdg.configFile."opencode/4.1-Beast.chatmode.md".source = impurity.link ./prompts/4.1-Beast.chatmode.md;
  };

  # localhost HTTPS development certs
  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  ];
}
