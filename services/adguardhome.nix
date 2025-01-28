{
  config,
  lib,
  hostname,
  myServiceOptions,
  ...
}:
with lib; let
  # Source: https://github.com/idrisr/nix-config/blob/main/nixos-modules/ad-blocker.nix
  # TODO: https://wiki.nixos.org/wiki/Adguard_Home
  nixpiTailscaleIp = "100.64.16.110";

  # The deployed server needs to have `tailscale set --accept-dns=false`
  cfg = config.michal.services.adguardhome;
in {
  options.michal.services.adguardhome =
    myServiceOptions "AdGuard Home"
    // {
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

  config = mkIf cfg.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [cfg.port];
        allowedUDPPorts = [53];
      };
    };

    services = {
      adguardhome = {
        enable = cfg.enable; # Always true?
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
              answer = nixpiTailscaleIp;
            }
            {
              domain = "*.${hostname}";
              answer = nixpiTailscaleIp;
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
