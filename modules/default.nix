{ pkgs, ... }:
{
  imports = [
    ./terminal.nix
    ./tailscale.nix
    ./cachix.nix
    ./docker.nix
    ./sops
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor
  ];
}
