{self, ...} @ attrs: let
  inherit (self) inputs;
  inherit (inputs) nixpkgs home-manager;

  # set the entrypoint for home-manager configurations
  homeDir = self + /homes;
  # create an alias for the home-manager nixos module
  hm = home-manager.nixosModules.home-manager;

  # if a host uses home-manager, then it can simply import this list
  homes = [
    homeDir
    hm
  ];
in {
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

        ./host
      ]
      ++ homes; # imports the home-manager related configurations
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
