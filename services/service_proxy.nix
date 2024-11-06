{ config, pkgs, hostname, runningServices, ... }:
with builtins;
let
  servicesList = map (name: 
      let
        cfg = runningServices.${name};
        subdomain = if (cfg ? subdomain) then cfg.subdomain else name;
      in 
      {
        name = "${subdomain}.${hostname}";
        value = {
          listen = [{ addr = "0.0.0.0"; port = 80; }];
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";  # Port where Homepage is running
          };
        };
      }
  ) (attrNames runningServices);

  virtualHosts = listToAttrs servicesList;
in
{
  services.nginx = {
    enable = true;
    inherit virtualHosts;
  };

  # open 80 port
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Local DNS configuration if using Pi-hole for DNS routing
  # networking.extraHosts = ''
  #   127.0.0.1 homepage.${hostname}
  #   127.0.0.1 adguard.${hostname}
  # '';
}
