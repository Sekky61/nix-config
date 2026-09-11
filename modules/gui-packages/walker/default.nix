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
  base64Helper = pkgs.writeShellApplication {
    name = "base64-helper";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
      walker
      wl-clipboard
    ];
    text = ''
      set -euo pipefail

      mode="''${1:-decode}"
      case "$mode" in
        decode)
          placeholder='Base64 decode'
          success_message='Base64 decoded'
          error_message='The input is not valid Base64.'
          ;;
        encode)
          placeholder='Base64 encode'
          success_message='Base64 encoded'
          error_message='Could not encode the input.'
          ;;
        *)
          printf 'Usage: %s [decode|encode]\n' "$0" >&2
          exit 2
          ;;
      esac

      input="$(walker --dmenu --placeholder "$placeholder")" || exit 0
      [[ -n "$input" ]] || exit 0

      output_file="$(mktemp)"
      trap 'rm -f "$output_file"' EXIT

      if [[ "$mode" == decode ]]; then
        if ! printf '%s' "$input" | base64 --decode >"$output_file" 2>/dev/null; then
          notify-send -a 'Walker' -u critical 'Base64 decode failed' "$error_message"
          exit 1
        fi
      elif ! printf '%s' "$input" | base64 --wrap=0 >"$output_file" 2>/dev/null; then
        notify-send -a 'Walker' -u critical 'Base64 encode failed' "$error_message"
        exit 1
      fi

      wl-copy <"$output_file"
      notify-send -a 'Walker' "$success_message" 'Result copied to clipboard.'
    '';
  };
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
      # | *      | bitwarden |
      # | (      | keybinds |

      programs.walker = {
        enable = true;
        runAsService = true;
        config = {
          providers = {
            prefixes = [
              {
                prefix = "@";
                provider = "websearch";
              }
              {
                prefix = "#";
                provider = "bluetooth";
              }
              {
                prefix = "*";
                provider = "bitwarden";
              }
              {
                prefix = "(";
                provider = "menus:keybinds";
              }
              {
                prefix = "~";
                provider = "menus:base64";
              }
            ];
          };
        };

        # Configure elephant through walker's elephant option
        # This integrates with the elephant service and triggers automatic restarts
        # That means, if you change something about bitwarden, that might not trigger and restart is needed
        elephant = {
          provider.menus.lua = {
            # `walker --provider menus:keybinds`
            keybinds = builtins.readFile ./keybinds.lua;
            # `walker --provider menus:base64`
            base64 = replaceStrings
              ["@BASE64_DECODE@" "@BASE64_ENCODE@"]
              [
                "${base64Helper}/bin/base64-helper decode"
                "${base64Helper}/bin/base64-helper encode"
              ]
              (builtins.readFile ./base64.lua);
          };
          provider = {
            bitwarden.settings = {
              name_pretty = "MyBitwarden";
            };
            websearch.settings = {
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
                  name = "Rust Crates";
                  url = "https://crates.io/search?q=%TERM%";
                  prefix = "r";
                }
                {
                  name = "Chat";
                  url = "https://chat.openai.com/?q=%TERM%";
                  prefix = "c";
                }
              ];
            };
          };
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
        command = {exec = walkerBin;};
      }
      {
        description = "Clipboard history";
        bind = {
          mods = ["SUPER"];
          key = "V";
        };
        command = {exec = "${walkerBin} --provider clipboard";};
      }
      {
        description = "Show keybinds menu";
        bind = {
          mods = ["SUPER" "SHIFT"];
          key = "K";
        };
        command = {exec = "${walkerBin} --provider menus:keybinds";};
      }
    ];
  };
}
