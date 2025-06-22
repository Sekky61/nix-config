{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.michal.browsers.firefox;
  mkBrowserOptions = import ./options.nix;
in {
  options.michal.browsers.firefox = mkBrowserOptions {
    inherit lib;
    execName = "firefox";
    desktopFileName = pkgs.firefox.desktopItem.name;
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      nativeMessagingHosts.packages = [pkgs.plasma5Packages.plasma-browser-integration];
    };

    environment.sessionVariables = lib.mkIf cfg.default {
      BROWSER = "firefox";
    };
  };
}
