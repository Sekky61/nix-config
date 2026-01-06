{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.obs-studio;
in {
  options.michal.programs.obs-studio = {
    enable = mkEnableOption "the obs studio program";
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        # todo remove, takes too long to update
        obs-backgroundremoval

        obs-pipewire-audio-capture
        obs-vaapi # obs hyprland support
        # droidcam-obs - use phone as a webcam
      ];
    };
  };
}
