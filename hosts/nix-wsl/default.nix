{username, ...}: {
  imports = [
    # HW
    ./configuration.nix

    # dev
    ../../modules/docker.nix
    ../../modules/dev
  ];

  michal = {
    graphical.enable = true;
    services = {
      tailscale = {
        enable = true;
        operator = username;
        systray.enable = true;
        exitNode = {
          enable = true;
        };
      };
    };
    programs = {
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
