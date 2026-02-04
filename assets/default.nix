{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.assets;
in {
  options.michal.assets = {enable = mkEnableOption "assets (wallpapers)";};

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.file = {".config/wallpapers".source = ./wallpapers;};
    };
  };
}
