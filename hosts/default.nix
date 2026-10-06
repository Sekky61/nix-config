{
  inputs,
  self,
  ...
}: let
  mkLib = nixpkgs:
    nixpkgs.lib.extend
    (final: prev: (import ../modules/lib.nix final) // inputs.home-manager.lib);

  lib = mkLib inputs.nixpkgs;

  nixosSystem = lib.nixosSystem;
  hosts = {
    nix-yoga = nixosSystem {
      specialArgs = {
        username = "michal";
        hostname = "nix-yoga";
        inherit inputs self lib;
      };
      modules = [
        ./common
      ];
    };

    nix-fw = nixosSystem {
      specialArgs = {
        username = "michal";
        hostname = "nix-fw";
        inherit inputs self lib;
      };
      modules = [
        ./common
      ];
    };

    nix-wsl = nixosSystem {
      specialArgs = {
        username = "michal";
        hostname = "nix-wsl";
        inherit inputs self lib;
      };
      modules = [
        ./common
      ];
    };

    nixpi = nixosSystem {
      system = "aarch64-linux";
      specialArgs = {
        username = "pi";
        hostname = "nixpi";
        inherit inputs self lib;
      };
      modules = [./nixpi];
    };

    homelab-apps = nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        username = "michal";
        hostname = "homelab-apps";
        inherit inputs self lib;
      };
      modules = [
        ../Homelab2/nixos/configuration.nix
        ({lib, ...}: {
          virtualisation.vmVariant.virtualisation.emptyDiskImages = [
            8192
            16384
          ];
          virtualisation.vmVariant.virtualisation.sharedDirectories.shared = {
            source = lib.mkForce "/tmp/homelab2-secrets";
            target = "/tmp/shared";
          };
        })
      ];
    };
  };

  # Impure versions of hosts
  impure-hosts = lib.mapAttrs' (name: config:
    lib.nameValuePair (name + "-impure") (config.extendModules {
      modules = [
        {
          config.michal.impurity.enable = true;
          config.michal.impurity.configRoot = ../.;
        }
      ];
    }))
  (lib.removeAttrs hosts ["nixpi" "homelab-apps"]);
in {
  flake.nixosConfigurations = hosts // impure-hosts;
}
