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
    ventoy.enable = true;
    borg.enable = true;
    alacritty.enable = true;
    ollama = {
      enable = true;
      gui = true;
    };
  };
}
