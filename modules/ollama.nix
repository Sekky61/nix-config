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
in
{
  options.michal.programs.ollama = {
    enable = mkEnableOption "ollama";
    gui = mkEnableOption "ollama gui";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm; # didnt detect gpu with normal ollama
      openFirewall = false;
      acceleration = "rocm";
      rocmOverrideGfx = "10.3.0";
    };

    services.nextjs-ollama-llm-ui = {
      enable = cfg.gui;
      port = 1300;
    };
  };
}
