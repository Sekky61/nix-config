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

  michal.sshKeys.personal.extraKeys = [
    # nixpi generated key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWLVyQyJlHKE7QOMe6Y6A2s87HSOxWl2YYiXE8wK9PS root@nixpi"
    # nix-yoga generated key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPfacGs1rirkWXU9N7Go7eEdZ/Je5V04h3sPzKkTOKgw root@michalyoga"
  ];

  networking.hostName = hostname;
}
