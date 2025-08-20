{inputs, ...}: let
  # List of outputs: https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs
  specialArgs = {
    inherit inputs;
    # customArgs = {
    #   files = ./../files;
    # };
  };
in {
  imports = [
    ./apps.nix
    ./checks.nix
    ./devshells.nix
    ./formatter.nix
    ./packages.nix
  ];
}
