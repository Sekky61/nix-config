{ pkgs, ... }:
{
  imports = [
    ./terminal.nix
    ./tailscale.nix
    ./cachix.nix
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor
  ];
}
