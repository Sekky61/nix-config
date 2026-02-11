{username, ...}: {
  imports = [
    # HW
    ./configuration.nix
  ];

  michal = {
    graphical.enable = true;
    dev.enable = true;
    programs = {
      claude-code.enable = true;
      codex.enable = true;
      docker.enable = true;
      opencode.enable = true;
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
