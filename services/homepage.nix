{ config, pkgs, hostname, runningServices, ... }:
let
  serviceCfg = runningServices.homepage;
  enable = serviceCfg != null;
in {
  # Source: https://github.com/V3ntus/nixos/blob/8cd44c2ea0d05e21701c8150abde892f4e76c0a8/hosts/homelab/net/homepage.nix
  services.homepage-dashboard = {
    inherit enable;
    listenPort = serviceCfg.port;

    environmentFile = config.sops.templates.homepage-env-file.path;

    # Client-side
    # customJS = ''
    #   // Log the entire environment (debug)
    #   console.log(process.env);
    # '';


    settings = {
      title = "The Homepage";
      startUrl = "http://${hostname}:${toString serviceCfg.port}";

      background = {
        blur = "sm";
        brightness = 50;
        opacity = 50;
      };
      theme = "dark";
      color = "slate";
      headerStyle = "clean";
      hideVersion = true;
      useEqualHeights = true;

      layout = {
        Apps = {
          tab = "Apps";
          style = "row";
          columns = 3;
          header = false;
        };
        Media = {
          tab = "Apps";
          style = "row";
          columns = 3;
        };
        Network = {
          tab = "System";
          style = "row";
          columns = 3;
        };
        Nixpi = {
          tab = "System";
          style = "row";
          columns = 3;
        };
      };
    };

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        search = {
          provider = "google";
          target = "_self";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            timeStyle = "short";
            dateStyle = "short";
            hourCycle = "h23";
          };
        };
      }
    ];

    bookmarks = [
      {
        "Bookmarks" = [
          {
            "YouTube" = [
              {
                icon = "youtube.svg";
                href = "https://youtube.com";
              }
            ];
          }
        ];
      }
      {
        "Misc" = [
          {
            "NixOS Configs" = [
              {
                icon = "github.svg";
                href = "https://github.com/V3ntus/nixos";
                description = "NixOS Config";
              }
            ];
          }
        ];
      }
    ];

    services = [
      {
        "Network" = [
          {
            "Unifi" = {
              icon = "unifi.png";
              description = "Unifi Site Manager";
              href = "https://unifi.ui.com";
            };
          }
        ];
      }
      {
        "Nixpi" = [
          {
            "Tailscale" = {
              description = "Tailscale Network";
              href = "https://login.tailscale.com/admin/machines";
              widget = {
                type = "tailscale";
                deviceid = "{{HOMEPAGE_VAR_NIXPI_TAILSCALE_ID}}";
                key = "{{HOMEPAGE_VAR_NIXPI_TAILSCALE_API_KEY}}";
              };
            };
          }
          {
            "AdGuardHome" = {
              description = "Adguard Home DNS filter";
              href = "http://nixpi:${builtins.toString config.adguardhome.port}";

              widget = {
                type = "adguard";
                url = "http://nixpi:${builtins.toString config.adguardhome.port}";
                username = config.adguardhome.admin.name;
                password = config.adguardhome.admin.password;
                latency = true;
              };
            };
          }
        ];
      }
    ];
  };
}
