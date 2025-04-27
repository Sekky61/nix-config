{
  description = "Michal's NixOS flake";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
      ];
      imports = [
        ./flake
        ./hosts
      ];
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    more-waita = {
      # Icons
      url = "github:somepaulo/MoreWaita";
      flake = false;
    };
    stylix.url = "github:danth/stylix";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    # raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
