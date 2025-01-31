{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.programs.chrome;
in {
  options.michal.programs.chrome = {
    enable = mkEnableOption "google chrome browser";
    default = mkEnableOption "google chrome to be the default browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libsForQt5.plasma-browser-integration
      google-chrome
      (pkgs.writeShellScriptBin "google-chrome" "exec -a $0 ${google-chrome}/bin/google-chrome-stable $@")
    ];

    # Theme: `rm -fr /etc/opt/chrome/policies/managed/` helped delete old color theme.

    # programs.chromium = {
    #   # This enables policies without installing the browser. Policies take up a
    #   # negligible amount of space, so it's reasonable to have this always on.
    #   enable = true;
    #
    #   extraOpts.BrowserThemeColor = config.michal.theme.secondaryContainer;
    # };

    environment.sessionVariables = mkIf cfg.default {
      BROWSER = "google-chrome";
    };
  };
}
