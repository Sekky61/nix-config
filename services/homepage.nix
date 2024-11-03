{ config, pkgs, domain, ... }:
{
  # Source: https://github.com/V3ntus/nixos/blob/8cd44c2ea0d05e21701c8150abde892f4e76c0a8/hosts/homelab/net/homepage.nix
  services.homepage-dashboard = {
    enable = true;
    listenPort = 1270; # Almost home
    settings = {
      title = "The Homepage";
      startUrl = "http://nixpi:1270";

      background = {
        image = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Moraine_Lake_17092005.jpg/640px-Moraine_Lake_17092005.jpg";
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
      {logo = {};}
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
        "Nixpi" = [
          {
          }
        ];
      }
    ];
  };
}
