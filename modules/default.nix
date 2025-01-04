{ pkgs, ... }:
{
  imports = [
    ./terminal.nix
    ./tailscale.nix
    ./cachix.nix
    ./docker.nix
    ./nix-config.nix
    ./sops

    # Modules with options
    ./bitwarden.nix
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor
  ];
}
