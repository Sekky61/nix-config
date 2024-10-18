{
  description = "Michal's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impurity.url = "github:outfoxxed/impurity.nix"; # Symlink config files

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      # inputs.nixpkgs.follows = "hyprland";
    };
    iio-hyprland.url = "github:JeanSchoeller/iio-hyprland";

    ags.url = "github:Aylur/ags/aaef50bb2c80ef4b4a359329d72669a95e7c4796";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    more-waita = {
      # Icons
      url = "github:somepaulo/MoreWaita";
      flake = false;
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });
    in {
      # editing flake.nix triggers certain utilities such as direnv
      # to reload - editing host configurations do not require a direnv
      # reload, so lets move hosts out of the way
      nixosConfigurations = import ./hosts inputs;

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default =
            pkgs.mkShell { buildInputs = with pkgs; [ nixfmt statix ]; };
        });

      formatter = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in pkgs.nixfmt-rfc-style );
    };
}
