{ config, lib, hostname, runningServices, ... }:
with lib;
let
  # Source: https://github.com/idrisr/nix-config/blob/main/nixos-modules/ad-blocker.nix

  # TODO: https://wiki.nixos.org/wiki/Adguard_Home

  # The deployed server needs to have `tailscale set --accept-dns=false`
  cfg = config.adguardhome;
  serviceCfg = runningServices.adguardhome;
  enable = serviceCfg != null;
in {

  options.adguardhome = {
    port = mkOption {
      type = types.int;
      default = serviceCfg.port;
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
        inherit enable;
        openFirewall = true;
        mutableSettings = true; # settings do not work without it!
        port = cfg.port;
        settings = {
          # bind_port = adguardPort;
          http = {
            address = "localhost:${builtins.toString cfg.port}";
          };
          filtering.rewrites = [
            {
              domain = hostname;
              answer = "100.64.16.110";
            }
            {
              domain = "*.${hostname}";
              answer = "100.64.16.110";
            }
          ];

          users = [
            # broken
            # cfg.admin
          ];
        };
      };
    };

  };
}
