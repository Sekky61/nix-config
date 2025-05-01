{
  self,
  inputs,
  lib,
}:
inputs.nixos-generators.nixosGenerate {
  system = "x86_64-linux";
  modules = [
    ../hosts/common

    # Desktop/gui
    ../modules/gui-packages
    ../modules/hyprland
    ../modules/gamedev/godot.nix
    ../assets

    # dev
    ../modules/terminal.nix
    ../modules/docker.nix
    ../modules/dev
    ({pkgs, ...}: {
      isoImage.squashfsCompression = "gzip -Xcompression-level 1";

      nixpkgs.config = {
        allowUnfree = true;
      };

      michal = {
        programs = {
          polkit.enable = true;
          ghostty = {
            enable = true;
            default = true;
          };
        };
        browsers = {
          chrome = {
            enable = true;
            default = true;
          };
        };
      };

      services = {
        spice-vdagentd.enable = true; # protocol for sharing clipboard with VMs
        pcscd.enable = true; # necessary? for gnupg
        envfs.enable = true;
        greetd = {
          enable = true;
          settings = {
            default_session = {
              # F1 to open commands
              # F2 to open sessions
              # F3 to open power menu
              command = ''${pkgs.greetd.tuigreet}/bin/tuigreet --greeting 'The royal PC is clean, your Highness' --user-menu --asterisks --time --remember --cmd Hyprland --kb-command 1 --kb-sessions 2 --kb-power 3'';
              user = "greeter";
            };
          };
        };
        gvfs.enable = true;
        xserver = {
          enable = true;
          displayManager.startx.enable = true;
          desktopManager.gnome = {
            enable = true;
            extraGSettingsOverridePackages = [
              pkgs.nautilus-open-any-terminal
            ];
          };
        };
      };
    })
  ];
  format = "iso";
  specialArgs = {
    username = "michal";
    hostname = "nix-yoga-live";
    inherit inputs self lib;
  };
}
