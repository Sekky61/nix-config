{ username, ... }: {
  imports = [
    # HW
    ./hardware-configuration.nix
    ./configuration.nix
    ./audio.nix

    # Desktop/gui
    ../../modules/hyprland

    # dev
    ../../modules/dev
  ];

  michal = {
    graphical.enable = true;
    assets.enable = true;
    hasFingerprintReader = true;
    programs = {
      docker.enable = true;
      ags.enable = false;
      waybar.enable = true;
      walker.enable = true;
      bitwarden.enable = true;
      obs-studio.enable = true;
      remote-desktop.enable = true;
      ventoy.enable = true;
      borg.enable = true;
      polkit.enable = true;
      ollama = {
        enable = false;
        gui = false;
      };
      steam.enable = true;
      alacritty.enable = true;
      kde-connect.enable = true;
      godot.enable = true;
      ghostty = {
        enable = true;
        default = true;
      };
      tailscale = {
        enable = true;
        operator = username;
        systray.enable = true;
        exitNode = { enable = true; };
      };
    };

    services = { battery.enable = true; };

    network = { cloudflare-warp.enable = true; };

    browsers = {
      zen = {
        enable = true;
        default = true;
      };
      chrome.enable = true;
    };

    monitors = [
      # Laptop monitor
      {
        id = "BOE 0x0BCA";
        width = 2256;
        height = 1504;
        refreshRate = 60;
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.333333; # It rejects uneven scales
        transform = 0;
      }
      # Desktop monitor
      {
        # Name is description from `hyprctl monitors`
        id = "GIGA-BYTE TECHNOLOGY CO. LTD. GIGABYTE G24F 22080B010444";
        width = 1920;
        height = 1080;
        refreshRate = 165;
        position = {
          x =
            1696; # 1920/1.333, next to laptop monitor, visualize with nwg-displays
          y = 0;
        };
        scale = 1;
        transform = 0;
      }
    ];
  };
}
