{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    # Truly common, always there
    ./btop.nix
    ./ssh.nix
    ./sops
    ./nix-config.nix
    ./cachix.nix
    ./locale.nix
    ./packages # admin/debug packages
    ./js-binfmt.nix
    ./overlays
    ./xdg.nix
    ./nvim
    ./bash
    ./terminal.nix

    # Modules with options
    ../assets
    ./audio.nix
    ./battery.nix
    ./network
    ./system/docker.nix
    ./system/podman.nix
    ./dev
    ./gui-packages
    ./bitwarden.nix
    ./ventoy.nix
    ./borg.nix
    ./ollama.nix
    ./theme
    ./impurity.nix
    ./gamedev
    ./waybar
    ./hyprland
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor # pretty nixos-switch
  ];

  _module.args.spicyPkgs = import inputs.nixpkgs-spicy {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
}
