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

    # Modules with options
    ./bitwarden.nix
    ./ventoy.nix
    ./borg.nix
    ./ollama.nix
    ./theme
    ./impurity.nix
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor # pretty nixos-switch
  ];
}
