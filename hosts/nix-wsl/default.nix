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

    michal.programs = {
    bitwarden.enable = true;
    obs-studio.enable = true;
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
}
