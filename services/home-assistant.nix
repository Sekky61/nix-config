{ config, lib, hostname, runningServices, pkgs, ... }:
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
    
    bedLampId = mkOption {
      type = with types; uniq str;
      default =  "1c35878105b007dee872426c985e9704";
      description = ''
        Device ID of bed lamp bulb. IDs can be found in the device URL in HA.
      '';
    };
  };

  config = {
    services.home-assistant = {
      inherit enable;
      extraComponents =  [
        # Components required to complete the onboarding
        "esphome"
        "met"
        "radio_browser"
        "isal"

        "homekit" # Apple

        "tuya"
        "ifttt"
        "telegram_bot"
      ];

      lovelaceConfig = {
        title = "My Home";
        views = [ {
          title = "Example";
          cards = [
            {
              type = "markdown";
              title = "Lovelace";
              content = "Welcome to your **Lovelace UI**.";
            }
            {
              type = "light";
              entity = "light.white";
              show_state = true;
              show_icon = true;
              tap_action = {action = "toggle";};
              hold_action = {action = "Default action";};
            }
            {
              type = "button";
              name = "Dim Light";
              icon = "mdi:lightbulb-on-10";
              entity = "script.dim_light";
              tap_action = {
                action = "toggle";
              };
            }
            {
              type = "button";
              name = "Normal Light";
              icon = "mdi:lightbulb-on-50";
              entity = "script.normal_light";
              tap_action = {
                action = "toggle";
              };
            }
            {
              type = "button";
              name = "Bright Light";
              icon = "mdi:lightbulb-on";
              entity = "script.bright_light";
              tap_action = {
                action = "toggle";
              };
            }
          ];
        } ];
      };
      lovelaceConfigWritable = true;
      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        zigbee2mqtt-networkmap
      ];

      customComponents = with pkgs.home-assistant-custom-components; [
        localtuya
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = {};
        http.server_port = cfg.port;
        homeassistant = {
          unit_system = "metric";
          name = "Home";
          # longitude = config.sops.placeholder."home/longitude";
          # latitude = config.sops.placeholder."home/latitude";
        };
        homekit = {
          name = "MyHub";
          filter = {
            include_domains = [ "light" "script" ];
          };
        };

        script = {
          dim_light = {
            alias = "Dim Light";
            sequence = [
              {
                event = "dim_light";
              }
            ];
          };
          normal_light = {
            alias = "Normal Light";
            sequence = [
              {
                event = "normal_light";
              }
            ];
          };
          bright_light = {
            alias = "Bright Light";
            sequence = [
              {
                event = "bright_light";
              }
            ];
          };
        };

        "automation manual" = [
          {
            alias = "Dim Light";
            triggers = [
              {
                trigger = "event";
                event_type = "dim_light";
              }
              {
                trigger = "event";
                event_type = "start_movie_time";
              }
            ];
            actions = [
              {
                action = "light.turn_on";
                target = {
                  device_id = cfg.bedLampId;
                };
                data = {
                  kelvin = 2000;
                  brightness_pct = 6;
                };
              }
            ];
          }
          {
            alias = "Dim Light";
            triggers = [
              {
                trigger = "event";
                event_type = "dim_light";
              }
              {
                trigger = "event";
                event_type = "start_movie_time";
              }
            ];
            actions = [
              {
                action = "light.turn_on";
                target = {
                  device_id = cfg.bedLampId;
                };
                data = {
                  kelvin = 2000;
                  brightness_pct = 6;
                };
              }
            ];
          }
          {
            alias = "Normal Light";
            trigger = {
              platform = "event";
              event_type = "normal_light";
            };
            actions = [
              {
                action = "light.turn_on";
                target = {
                  device_id = cfg.bedLampId;
                };
                data = {
                  kelvin = 2500;
                  brightness_pct = 50;
                };
              }
            ];
          }
          {
            alias = "Bright Light";
            trigger = {
              platform = "event";
              event_type = "bright_light";
            };
            actions = [
              {
                action = "light.turn_on";
                target = {
                  device_id = cfg.bedLampId;
                };
                data = {
                  kelvin = 6000;
                  brightness_pct = 100;
                };
              }
            ];
          }
        ];
        "automation ui" = "!include automations.yaml";
      };
      # configWritable = true; # HA crashes
    };

    # prevents a fail
    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    ];

    services.zigbee2mqtt.enable = true;
  };
}
