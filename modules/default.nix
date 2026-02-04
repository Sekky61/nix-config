{pkgs, ...}: {
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
    ./gui-packages
    ./bitwarden.nix
    ./ventoy.nix
    ./borg.nix
    ./ollama.nix
    ./theme
    ./impurity.nix
    ./gamedev
    ./waybar
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor # pretty nixos-switch
  ];
}
