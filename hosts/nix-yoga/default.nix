{
  imports = [
    # HW
    ./hardware-configuration.nix
    ./configuration.nix
    ./audio.nix
    ./laptop.nix

    # Desktop/gui
    ../../modules/hyprland

    # dev
    ../../modules/dev
  ];

  michal = {
    graphical.enable = true;
    assets.enable = true;
    programs = {
      docker.enable = true;
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
        id = "Samsung Display Corp. 0x4193";
        width = 2880;
        height = 1800;
        refreshRate = 90.0;
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
