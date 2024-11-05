{ config, lib, ... }:
with lib;
let
  # Source: https://github.com/idrisr/nix-config/blob/main/nixos-modules/ad-blocker.nix

  # The deployed server needs to have `tailscale set --accept-dns=false`
  adguardPort = 1280;
in {
  networking = {
    firewall = {
      allowedTCPPorts = [ adguardPort ];
      allowedUDPPorts = [ 53 ];
    };
  };

  services = {
    adguardhome = {
      enable = true;
      openFirewall = true;
      port = adguardPort;
      settings = {
        # bind_port = adguardPort;
        schema_version = 20;
      };
    };
  };
}
