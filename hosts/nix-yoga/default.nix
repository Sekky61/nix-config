{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix

    ./audio.nix
    ./gnome.nix
    ./laptop.nix
    ./locale.nix

    ../../modules/dev
    ../../modules/gui-packages
    ../../modules/hyprland.nix
    ../../modules/browser/chrome.nix
    ../../modules/gamedev/godot.nix
  ];

  michal.programs = {
    bitwarden.enable = true;
    ventoy.enable = true;
  };
}
