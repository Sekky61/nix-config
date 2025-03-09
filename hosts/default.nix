{
  inputs,
  system,
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

    nix-wsl = nixosSystem {
      specialArgs = {
        username = "michal";
        hostname = "nix-wsl";
        inherit inputs self lib;
      };
      system = "x86_64-linux";
      modules = [
        ./common
      ];
    };

    nixpi = nixosSystem {
      specialArgs = {
        username = "pi";
        hostname = "nixpi";
        inherit inputs self;
      };
      system = "aarch64-linux";
      modules = [
        ./common
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
  hosts;
in {
  flake.nixosConfigurations =
    hosts
    // impure-hosts
    // {
      desktopIso = nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ../modules/ssh.nix
          ({
            pkgs,
            modulesPath,
            ...
          }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
            ];
            environment.systemPackages = [pkgs.neovim];
          })
        ];
      };

      minimal-pi = nixosSystem {
        specialArgs = {
          username = "pi";
          hostname = "rpi";
          inherit inputs;
        };
        system = "aarch64-linux";
        modules = [
          ../modules/ssh.nix
          ({username, ...}: {
            users.users.root.initialPassword = "root";
            users.users.${username} = {
              initialPassword = "password";
              isNormalUser = true;
              group = "pi";
            };
            users.groups.pi = {};
          })
        ];
      };
    };
}
