{hostname, ...}: {
  # Sources for writing modules:
  # https://nixos.org/manual/nixos/stable/#sec-writing-modules
  # https://nixos.wiki/wiki/NixOS_modules

  imports = [
    # Import based on hostname
    ../${hostname}
    # Imports based on username
    ../../homes
    # And common stuff
    ../../modules
    ../../services # each must be enabled
  ];

  # SSH

  networking.hostName = hostname;
}
