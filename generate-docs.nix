{ pkgs, inputs, ... }:
let
  lib = pkgs.lib;

  eval = lib.evalModules {
    modules = [
      ({ lib, ... }: {
        config._module.check = false;

        options.michal.theme = lib.mkOption {
          type = with lib.types; attrsOf str;
          default = { };
          description = ''
            Keyed colors. Assume #RRGGBB. Names like primary, surface.
          '';
          example = {
            primary = "#8dcdff";
            outline = "#8b9198";
            error = "#ffb4a9";
          };
        };

        options.programs = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Stub programs namespace for docs generation.";
        };
      })
      ./modules/audio.nix
      ./modules/battery.nix
      ./modules/bitwarden.nix
      ./modules/borg.nix
      ./modules/gamedev/godot.nix
      ./modules/gamedev/unity.nix
      ./modules/gui-packages/ags/default.nix
      ./modules/gui-packages/kde-connect.nix
      ./modules/gui-packages/monitors.nix
      ./modules/gui-packages/obs.nix
      ./modules/gui-packages/options.nix
      ./modules/gui-packages/remote-desktop.nix
      ./modules/gui-packages/steam.nix
      ./modules/gui-packages/terminal-emulator/alacritty.nix
      ./modules/gui-packages/terminal-emulator/default.nix
      ./modules/gui-packages/terminal-emulator/ghostty.nix
      ./modules/gui-packages/walker.nix
      ./modules/gui-packages/browser/chrome.nix
      ./modules/gui-packages/browser/firefox.nix
      ./modules/gui-packages/browser/zen.nix
      ./modules/hyprland/auth.nix
      ./modules/hyprland/hyprlock.nix
      ./modules/hyprland/keybinds.nix
      ./modules/impurity.nix
      ./modules/network/cloudflare-warp.nix
      ./modules/network/tailscale.nix
      ./modules/network/wifi.nix
      ./modules/ollama.nix
      ./modules/ssh.nix
      ./modules/ventoy.nix
      ./modules/waybar/default.nix
      ./services/default.nix
    ];
    specialArgs = {
      inherit inputs pkgs;
      username = "docs";
      hostname = "docs";
    };
  };

  # Output shape: options.json is a map of option names to metadata.
  # Example keys: declarations, default (literalExpression), description, example,
  # loc (path list), readOnly, type.
  docs = pkgs.nixosOptionsDoc {
    options = eval.options;
    warningsAreErrors = false;
  };
in pkgs.runCommand "michal-options-docs" { } ''
  mkdir -p "$out"
  cp ${docs.optionsJSON}/share/doc/nixos/options.json "$out/options.json"
''
