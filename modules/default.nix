{pkgs, ...}: {
  imports = [
    # Truly common, always there
    ./tailscale.nix
    ./ssh.nix
    ./sops
    ./nix-config.nix
    ./cachix.nix
    ./locale.nix
    ./packages # admin/debug packages
    ./js-binfmt.nix
    ./overlays
    ./xdg.nix

    # Modules with options
    ./gui-packages
    ./bluetooth.nix
    ./bitwarden.nix
    ./ventoy.nix
    ./borg.nix
    ./ollama.nix
    ./theme
    ./impurity.nix
    ./gamedev
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor # pretty nixos-switch
  ];
}
