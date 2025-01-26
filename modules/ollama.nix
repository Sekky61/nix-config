{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.michal.programs.ollama;

  # Default port 11434
  # GUI at http://127.0.0.1:1300
  # TODO proxy
  # CPU only - rocm being rocm
in
{
  options.michal.programs.ollama = {
    enable = mkEnableOption "ollama";
    gui = mkEnableOption "ollama gui";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      openFirewall = false;
      acceleration = false;
    };

    services.nextjs-ollama-llm-ui = {
      enable = cfg.gui;
      port = 1300;
    };
  };
}
