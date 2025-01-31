{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.programs.firefox;
in {
  options.michal.programs.firefox = {
    enable = mkEnableOption "firefox browser";
    default = mkEnableOption "firefox to be the default browser";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      nativeMessagingHosts.packages = [pkgs.plasma5Packages.plasma-browser-integration];
    };

    environment.sessionVariables = mkIf cfg.default {
      BROWSER = "firefox";
    };
  };
}
