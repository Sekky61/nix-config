{ self, hostname, inputs, ... }: {
  # Sources for writing modules:
  # https://nixos.org/manual/nixos/stable/#sec-writing-modules
  # https://nixos.wiki/wiki/NixOS_modules

  imports = [
    # Import based on hostname
    ../${hostname}
    # Imports based on username
    ../../homes

    # And common stuff
    ../../assets
    ../../modules
    {
      # Impurity
      imports = [ inputs.impurity.nixosModules.impurity ];
      impurity.configRoot = self;
      # impurity.enable = true; # this is enabled by "*-impure" nixosconfigs
    }

  ];


  networking.hostName = hostname;
}
