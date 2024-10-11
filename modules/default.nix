{home-manager, ...}: {
  imports = [
    # home-manager.nixosModules.home-manager
    ./ssh.nix
    ./bash
  ];
}
