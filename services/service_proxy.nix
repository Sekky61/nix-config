{
  config,
  lib,
  hostname,
  ...
}:
with builtins;
with lib; let
  cfg = config.michal.services.proxy;

  allRunningServicesOptions =
    filterAttrs (n: v: n != "proxy" && (v ? enable && v.enable) && (v ? proxy && v.proxy))
    config.michal.services;

  # https://noogle.dev/f/lib/mapAttrs'
  virtualHosts =
    mapAttrs' (
      name: serviceCfg: let
        subdomain =
          if (serviceCfg ? subdomain)
          then serviceCfg.subdomain
          else name;
      in {
        name = "${subdomain}.${hostname}";
        value = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 80;
            }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString serviceCfg.port}"; # Port where Homepage is running
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
      }
    )
    allRunningServicesOptions;
in {
  options.michal.services.proxy = {
    enable = mkEnableOption "the service proxy"; # Prefixes "Whether to enable "
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = cfg.enable;
      inherit virtualHosts;
    };

    networking.firewall.allowedTCPPorts = [80];

    # Local DNS configuration if using Pi-hole for DNS routing
    #
    # networking.extraHosts = ''
    #   127.0.0.1 homepage.${hostname}
    #   127.0.0.1 adguard.${hostname}
    # '';
  };
}
