{
  imports = [
    # HW
    ./hardware-configuration.nix
    ./configuration.nix
    ./audio.nix
    # ../../modules/wifi.nix

    # Desktop/gui
    ../../modules/hyprland
    ../../assets

    # dev
    ../../modules/docker.nix
    ../../modules/dev
  ];

  michal = {
    graphical.enable = true;
    programs = {
      ags.enable = true;
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
    };

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
        id = "eDP-1";
        width = 2256;
        height = 1504;
        refreshRate = 60.0;
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.5;
        transform = 0;
      }
      # Desktop monitor
      {
        id = "Gigabyte Technology Co. Ltd. G27QC A";
        width = 1920;
        height = 1080;
        refreshRate = 165.0;
        position = {
          x = 1920;
          y = 0;
        };
        scale = 1;
        transform = 0;
      }
    ];
  };
}
