{username, ...}: {
  imports = [
    # HW
    ./configuration.nix

    # dev
    ../../modules/dev
  ];

  michal = {
    graphical.enable = true;
    programs = {
      docker.enable = true;
      tailscale = {
        enable = true;
        operator = username;
        systray.enable = true;
        exitNode = {enable = true;};
      };
      bitwarden.enable = true;
      remote-desktop.enable = true;
      ventoy.enable = true;
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
