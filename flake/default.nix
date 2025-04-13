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
    ./checks.nix
    ./devshells.nix
    ./packages.nix
  ];

  perSystem = {
    system,
    pkgs,
    ...
  }: {
    # Runs on save in nvim or with `nix fmt`
    formatter = pkgs.alejandra;
  };
}
