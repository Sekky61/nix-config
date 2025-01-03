{ self, hostname, inputs, ... }: {
  imports = [
    # Import based on hostname
    ../${hostname}
    # Imports based on username
    ../../homes

    # And common stuff
    ../../assets
    ../../modules
    inputs.sops-nix.nixosModules.sops # important to include "inputs"
    {
      # Impurity
      imports = [ inputs.impurity.nixosModules.impurity ];
      impurity.configRoot = self;
      # impurity.enable = true; # this is enabled by "*-impure" nixosconfigs
    }

  ];


  networking.hostName = hostname;
}
