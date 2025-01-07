{ nixpkgs, ... } @ inputs: 
let 
  lib = nixpkgs.lib;
  nixosSystem = lib.nixosSystem;
  hosts = {
    nix-yoga = nixosSystem {
      specialArgs = {
        username = "michal";
        hostname = "nix-yoga";
        inherit inputs;
      };
      modules = [
        ./common
      ];
    };

    nixpi = nixosSystem {
      specialArgs = {
        username = "pi";
        hostname = "nixpi";
        inherit inputs;
      };
      system = "aarch64-linux";
      modules = [
        ./common
      ];
    };
  };

  impure-hosts = lib.mapAttrs' (name: config: lib.nameValuePair (name + "-impure") (config.extendModules { modules = [
    { impurity.enable = true; }
  ]; })) hosts;

in hosts // impure-hosts // {

  desktopIso = nixosSystem {
    specialArgs = { inherit inputs; };
    system = "x86_64-linux";
    modules = [
      ../modules/ssh.nix
      ({ pkgs
       , modulesPath
       , ...
       }: {
        imports = [ 
          (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
        ];
        environment.systemPackages = [ pkgs.neovim ];
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
      ({ username, ... }: {
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
}
