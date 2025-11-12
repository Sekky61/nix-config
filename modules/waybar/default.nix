{
  username,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.waybar;
in {
  options.michal.programs.waybar = {
    enable = mkEnableOption "waybar";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.waybar = {
        enable = true;
        systemd = {
          enable = true;
          # enableInspect = true;
        };
      };

      home.file.".config/waybar/config".source = ./config;
      home.file.".config/waybar/style.css".source = ./waybar.css;
    };
  };
}
