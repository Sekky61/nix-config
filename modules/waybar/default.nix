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
        settings = {
          # bar is a made-up key. Can be anything
          bar = builtins.fromJSON (builtins.readFile ./config.json);
        };
        style = ./waybar.css;
        systemd = {
          enable = true;
          # enableInspect = true;
        };
      };
    };
  };
}
