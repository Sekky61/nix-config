{
  inputs,
  username,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.walker;
  walkerBin = "${pkgs.walker}/bin/walker";
in {
  options.michal.programs.walker = {
    enable = mkEnableOption "walker application launcher";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      imports = [inputs.walker.homeManagerModules.default];

      # app launcher
      #
      # Docs: https://benz.gitbook.io/walker/
      #
      # | prefix | provider  |
      # |--------|-----------|
      # | .      | emojis    |
      # | :      | clipboard |
      # | >      | runner    |
      # | /      | file search |
      # | $      | windows   |
      # | @      | websearch (@g for github etc.) |
      # | #      | bluetooth |
      # | =      | calc      |
      # | %      | bookmarks |
      # | !      | todo      |
      # | ;      | provider list |
      # | |      | bitwarden |

      programs.walker = {
        enable = true;
        runAsService = true;
        config = {
          providers = {
            prefixes = [
              { prefix = "@"; provider = "websearch"; }
              { prefix = "#"; provider = "bluetooth"; }
              { prefix = "|"; provider = "bitwarden"; } # bw needs newer version
            ];
          };
        };

        # Configure elephant through walker's elephant option
      # This integrates with the elephant service and triggers automatic restarts
      elephant = {
        provider.websearch.settings = {
          # Show each search engine as a separate item instead of as actions
          # This allows you to see all engines when typing your query
          engines_as_actions = false;

          entries = [
            {
              default = true;
              name = "DuckDuckGo";
              url = "https://duckduckgo.com/?q=%TERM%";
              prefix = "d";
            }
            {
              name = "GitHub";
              url = "https://github.com/search?q=%TERM%";
              prefix = "g";
            }
            {
              name = "Nix packages";
              url = "https://search.nixos.org/packages?channel=unstable&query=%TERM%";
              prefix = "n";
            }
            {
              name = "Crates";
              url = "https://crates.io/search?q=%TERM%";
              prefix = "c";
            }
          ];
        };
      };
      };

      wayland.windowManager.hyprland = {
        settings = {
          gesture = [
            "4, down, dispatcher, exec, ${walkerBin}"
          ];
        };
      };
    };

    michal.programs.hyprland.keybinds = [
      {
        description = "Launch application launcher";
        bind = {
          mods = ["SUPER"];
          key = "Space";
        };
        command = {params = walkerBin;};
      }
    ];
  };
}
