{ pkgs, ... }:
{
  imports = [
    ./terminal.nix
    ./tailscale.nix
  ];

  environment.systemPackages = with pkgs; [
    nix-output-monitor
  ];
}
