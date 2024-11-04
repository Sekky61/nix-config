{ pkgs, ... }:
{
  imports = [
    ./terminal.nix
    ./tailscale.nix
    ./cachix.nix
    ./sops
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor
  ];
}
