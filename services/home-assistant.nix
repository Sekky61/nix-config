{ config, lib, hostname, runningServices, ... }:
with lib;
let
  cfg = config.home-assistant;
  serviceCfg = runningServices.home-assistant;
  enable = serviceCfg != null;
in {

  options.home-assistant = {
    port = mkOption {
      type = types.int;
      default = serviceCfg.port;
      description = ''
        The port to run home-assistant on
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

    services.home-assistant = {
      inherit enable;
      extraComponents = [
        # Components required to complete the onboarding
        "esphome"
        "met"
        "radio_browser"
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = {};
      };
    };
  };
}
