{
  imports = [
    # HW
    ./hardware-configuration.nix
    ./configuration.nix
    ./audio.nix
    ./laptop.nix
    # ../../modules/wifi.nix

    # Desktop/gui
    ./gnome.nix
    ../../modules/gui-packages
    ../../modules/hyprland
    ../../modules/gamedev/godot.nix
    ../../assets

    # dev
    ../../modules/terminal.nix
    ../../modules/docker.nix
    ../../modules/dev
  ];

  michal.programs = {
    bitwarden.enable = true;
    ventoy.enable = true;
    borg.enable = true;
    polkit.enable = true;
    ollama = {
      enable = true;
      gui = true;
    };
    zen = {
      enable = true;
      default = true;
    };
    chrome.enable = true;
    steam.enable = true;
    alacritty.enable = true;
    ghostty = {
      enable = true;
      default = true;
    };
  };
}
