{ config, lib, ... }:
with lib;
let
  # Source: https://github.com/idrisr/nix-config/blob/main/nixos-modules/ad-blocker.nix

  # TODO: https://wiki.nixos.org/wiki/Adguard_Home

  # The deployed server needs to have `tailscale set --accept-dns=false`
  cfg = config.adguardhome;
in {

  options.adguardhome = {
    port = mkOption {
      type = types.int;
      default = 1280;
      description = ''
        The port to run AdGuard Home
      '';
    };

    admin = mkOption {
      type = types.attrs;
      default = {
        name = "admin";
        password = "$2a$10$peRQvZ3wLnbfwVFIc.u0ceSxAnrZ4yWF32Hq9UpnJDr3fWqIhHWpW";
      };
      description = ''
      The admin username and password
      '';
    };
  };

  config = {

    networking = {
      firewall = {
        allowedTCPPorts = [ cfg.port ];
        allowedUDPPorts = [ 53 ];
      };
    };

    services = {
      adguardhome = {
        enable = true;
        openFirewall = true;
        port = cfg.port;
        settings = {
          # bind_port = adguardPort;
          schema_version = 20;
          http = {
            address = "localhost:${builtins.toString cfg.port}";
          };

          users = [
            # broken
            # cfg.admin
          ];
        };
      };
    };

  };
}
