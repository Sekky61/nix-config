{
  imports = [
    # HW
    ./configuration.nix

    # dev
    ../../modules/terminal.nix
    ../../modules/docker.nix
    ../../modules/dev

    # GUI
    ../../modules/gui-packages/alacritty.nix
  ];

  michal.programs = {
    bitwarden.enable = true;
    ventoy.enable = true;
    borg.enable = true;
    ollama = {
      enable = true;
      gui = true;
    };
  };
}
