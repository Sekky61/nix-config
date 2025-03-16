{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.ghostty;
  ghostty = "ghostty";
in {
  options.michal.programs.ghostty = {
    enable = mkEnableOption ghostty;
    default = mkEnableOption "ghostty to be the default terminal emulator";
  };
  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.ghostty = {
        enable = true;
        enableBashIntegration = true;
      };
    };

    michal.environment = mkIf cfg.default {
      terminal = ghostty;
    };
  };
}
