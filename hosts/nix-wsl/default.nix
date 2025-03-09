{
  imports = [
    # HW
    ./configuration.nix

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
  };
}
