{
  self,
  nixpkgs,
  raspberry-pi-nix,
  ...
} @ inputs: {
  michal = nixpkgs.lib.nixosSystem {
    specialArgs = {
      username = "michal";
      hostname = "nix-yoga";
      inherit inputs;
    };
    modules = [
      {
        # Impurity
        imports = [inputs.impurity.nixosModules.impurity];
        impurity.configRoot = self;
        impurity.enable = true;
      }

      ../homes # Imports based on username
      ./host # Imports based on hostname
      ../modules
      ../modules/ssh.nix
      ../modules/terminal-gui.nix
      ../modules/user-packages.nix
      ../modules/dev.nix
    ];
  };

  # https://github.com/outfoxxed/impurity.nix
  michal-impure = self.nixosConfigurations.michal.extendModules {modules = [{impurity.enable = true;}];};

  rpi = nixpkgs.lib.nixosSystem {
    specialArgs = {
      username = "pi";
      hostname = "nixpi";
      inherit inputs;
    };
    system = "aarch64-linux";
    modules = [
      {
        # Impurity
        imports = [inputs.impurity.nixosModules.impurity];
        impurity.configRoot = self;
        impurity.enable = true;
      }
      raspberry-pi-nix.nixosModules.raspberry-pi
      ./rpi.nix
      ../modules
      ../homes # Imports based on username
    ];
  };

  desktopIso = nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    system = "x86_64-linux";
    modules = [
      ({
        pkgs,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];
        environment.systemPackages = [pkgs.neovim];
      })
    ];
  };
}
