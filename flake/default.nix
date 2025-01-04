{ inputs, ... }:
let
  # List of outputs: https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs

  specialArgs = {
    inherit inputs;
    # customArgs = {
    #   files = ./../files;
    # };
  };
in
{
  imports = [
    # ./checks.nix
    # ./devshells.nix
    ./packages.nix
  ];

  flake = {
    # templates = import ./../templates;

    nixosConfigurations = import ../hosts inputs;
  };

  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ ];
      };

      formatter = pkgs.nixfmt-rfc-style;

      devShells = {
        default = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt statix ]; };
      };
    };
}
