{username, ...}: {
  imports = [
    # HW
    ./hardware-configuration.nix
    ./configuration.nix
  ];

  michal.programs.podman.enable = true;
  # michal.programs.docker.enable = true;

  home-manager.users.${username}.programs.safe-chain = {
    enable = true;
    integration = "pathShims";
  };

  michal = {
    audio = {
      enable = true;
      guiTools = true;
    };
    assets.enable = true;
    dev.enable = true;
    graphical.enable = true;
    hyprland.enable = true;
    programs = {
      claude-code.enable = true;
      codex.enable = true;
      hunk.enable = true;
      pi.enable = true;
      opencode.enable = true;
      dms-shell.enable = true;
      waybar.enable = false;
      walker.enable = true;
      bitwarden.enable = true;
      gpu-screen-recorder.enable = true;
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
      three-d-printing.enable = true;
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
        exitNode = {enable = true;};
      };
    };

    services = {battery.enable = true;};

    network = {cloudflare-warp.enable = true;};

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
      # Gaming desktop monitor
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
      # Work desktop monitor
      {
        # Name is description from `hyprctl monitors`
        id = "AOC U32G4U ZPYS4JA001734";
        width = 3840;
        height = 2160;
        # 4K 160 Hz needs HDMI 2.1 FRL (48 Gb/s) or DP 1.4 HBR3 with DSC.
        # The Framework HDMI Expansion Card is HDMI 2.0b and supports 4K 60 Hz.
        refreshRate = 60;
        position = {
          x = 1692; # 2256/1.333, next to laptop monitor
          y = 0;
        };
        scale = 1.25;
        transform = 0;
      }
    ];
  };
}
