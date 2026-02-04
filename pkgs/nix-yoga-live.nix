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
    ../modules/hyprland

    # dev
    ../modules/system/docker.nix
    ../modules/dev
    ({pkgs, ...}: {
      isoImage.squashfsCompression = "gzip -Xcompression-level 1";

      nixpkgs.config = {allowUnfree = true;};

      michal = {
        graphical.enable = true;
        assets.enable = true;
        programs = {
          polkit.enable = true;
          ghostty = {
            enable = true;
            default = true;
          };
        };
        browsers = {
          zen = {
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
              command = "${pkgs.tuigreet}/bin/tuigreet --greeting 'The royal PC is clean, your Highness' --user-menu --asterisks --time --remember --cmd start-hyprland --kb-command 1 --kb-sessions 2 --kb-power 3";
              user = "greeter";
            };
          };
        };
        gvfs.enable = true;
        desktopManager.gnome.enable = {
          enable = true;
          extraGSettingsOverridePackages = [pkgs.nautilus-open-any-terminal];
        };

        xserver = {
          enable = true;
          displayManager.startx.enable = true;
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
