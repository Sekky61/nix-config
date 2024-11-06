{ config, pkgs, hostname, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "homepage.${hostname}" = {
        listen = [{ addr = "0.0.0.0"; port = 80; }];
        locations."/" = {
          proxyPass = "http://127.0.0.1:1270";  # Port where Homepage is running
        };
      };

      "adguard.${hostname}" = {
        listen = [{ addr = "0.0.0.0"; port = 80; }];
        locations."/" = {
          proxyPass = "http://127.0.0.1:1280";  # Port where Pi-hole is running
        };
      };
    };
  };

  # open 80 port
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Local DNS configuration if using Pi-hole for DNS routing
  # networking.extraHosts = ''
  #   127.0.0.1 homepage.${hostname}
  #   127.0.0.1 adguard.${hostname}
  # '';
}
