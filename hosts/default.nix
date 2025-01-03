{ self
, nixpkgs
, sops-nix
, ...
} @ inputs: 
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
        {
          # Impurity
          imports = [ inputs.impurity.nixosModules.impurity ];
          impurity.configRoot = self;
          # impurity.enable = true;
        }
        sops-nix.nixosModules.sops # Couldnt solve it in sops module

        ../homes # Imports based on username
        ./host   # Imports based on hostname
        ../assets
        ../modules
        ../modules/dev
        ../modules/packages
        ../modules/gui-packages
        ../modules/hyprland.nix
        ../modules/ssh.nix
        ../modules/browser/chrome.nix
        ../modules/gamedev/godot.nix
      ];
    };

    nixpi = nixosSystem {
      specialArgs = {
        username = "pi";
        hostname = "nixpi";
        runningServices = {
          homepage = {
            port = 1270;
            subdomain = "homepage";
          };
          adguardhome = {
            port = 1280;
            subdomain = "adguard";
          };
          home-assistant = {
            port = 1290;
            subdomain = "homeassistant";
          };
        };
        inherit inputs;
      };
      system = "aarch64-linux";
      modules = [
        {
          # Impurity
          imports = [ inputs.impurity.nixosModules.impurity ];
          impurity.configRoot = self;
          # impurity.enable = true;
        }
        sops-nix.nixosModules.sops
        # raspberry-pi-nix.nixosModules.raspberry-pi

        ./rpi
        # ./rpi.nix
        ../modules
        ../homes # Imports based on username

        # Services
        ../services # controlled by runningServices
      ];
    };
  };

  impure-hosts = lib.mapAttrs' (name: config: lib.nameValuePair (name + "-impure") (config.extendModules { modules = [{ impurity.enable = true; }]; })) hosts;
in hosts // impure-hosts // {

  desktopIso = nixosSystem {
    specialArgs = { inherit inputs; };
    system = "x86_64-linux";
    modules = [
      ({ pkgs
       , modulesPath
       , ...
       }: {
        imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
        environment.systemPackages = [ pkgs.neovim ];
      })
    ];
  };

}
