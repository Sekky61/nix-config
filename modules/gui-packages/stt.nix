{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.programs.stt;
in {
  options.michal.programs.stt = {
    enable = mkOption {
      type = types.bool;
      default = config.michal.graphical.enable;
      description = "speech-to-text tools";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      curl
      screen
      sox
      ydotool
    ];
  };

  # Needs ydotool to be launched on startup
}
