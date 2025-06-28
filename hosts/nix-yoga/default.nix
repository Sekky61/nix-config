{
  imports = [
    # HW
    ./hardware-configuration.nix
    ./configuration.nix
    ./audio.nix
    ./laptop.nix
    # ../../modules/wifi.nix

    # Desktop/gui
    ../../modules/gui-packages
    ../../modules/hyprland
    ../../assets

    # dev
    ../../modules/terminal.nix
    ../../modules/docker.nix
    ../../modules/dev
  ];

  michal = {
    programs = {
      bitwarden.enable = true;
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
  };
}
