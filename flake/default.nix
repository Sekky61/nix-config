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
    # ./checks.nix
    # ./devshells.nix
    ./packages.nix
    ../hosts
  ];

  # flake = {
  #   templates = import ./../templates;
  # };

  perSystem = {
    system,
    pkgs,
    ...
  }: {
    formatter = pkgs.alejandra;

    devShells = {
      default = pkgs.mkShell {buildInputs = with pkgs; [nixfmt statix];};
    };
  };
}
