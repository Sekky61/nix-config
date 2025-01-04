{ config, lib, hostname, ... }:
with lib;
let
  myServiceOptions = serviceName: with lib; {
    
    enable = mkEnableOption "the ${serviceName} service"; # Prefixes "Whether to enable "

    port = mkOption {
      type = types.ints.u16;
      description = ''
        The port to run ${serviceName} on
      '';
    };

    subdomain = mkOption {
      type = types.str;
      description = ''
        The subdomain to expose ${serviceName} on
      '';
    };
  };
in {
  imports = []
    ++ [
      # Proxy all services
      ./service_proxy.nix

      # The Services
      ./adguardhome.nix
      ./home-assistant.nix
      ./homepage.nix
    ];

  # Add my generic options to lib
  _module.args = {
    inherit myServiceOptions;
  };

}
