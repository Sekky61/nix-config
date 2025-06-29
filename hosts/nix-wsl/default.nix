{
  imports = [
    # HW
    ./configuration.nix

    # dev
    ../../modules/terminal.nix
    ../../modules/docker.nix
    ../../modules/dev

    # GUI
    ../../modules/gui-packages/terminal-emulator
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
      alacritty = {
        enable = true;
        default = true;
      };
      ollama = {
        enable = true;
        gui = true;
      };
    };
  };
}
