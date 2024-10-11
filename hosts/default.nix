{self, nixpkgs, ...} @ inputs: {
  michal = nixpkgs.lib.nixosSystem {
    specialArgs = {
      username = "michal";
      hostname = "nix-yoga";
      inherit inputs;
    };
    modules =
      [
        {
          # Impurity
          imports = [inputs.impurity.nixosModules.impurity];
          impurity.configRoot = self;
          impurity.enable = true;
        }

        ../homes
        ./host
      ];
  };

  # https://github.com/outfoxxed/impurity.nix
  michal-impure = self.nixosConfigurations.michal.extendModules {modules = [{impurity.enable = true;}];};

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
