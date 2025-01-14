{
  imports = [
    # HW
    ./hardware-configuration.nix
    ./configuration.nix
    ./audio.nix
    ./laptop.nix
    ../../modules/wifi.nix

    # Desktop/gui
    ./gnome.nix
    ../../modules/gui-packages
    ../../modules/hyprland
    ../../modules/browser/chrome.nix
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

  };
}
