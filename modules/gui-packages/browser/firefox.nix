/*
  Firefox Browser Configuration

  This module configures Mozilla Firefox using the standard NixOS firefox program.
  Firefox has excellent NixOS integration through the programs.firefox module.
*/
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
    # Use the standard NixOS Firefox program module for proper integration
    programs.firefox = {
      enable = true;
      # TODO: Consider enabling KDE Plasma browser integration for enhanced desktop features
      # nativeMessagingHosts.packages = [pkgs.kdePackages.plasma-browser-integration];
    };

    # Set BROWSER environment variable when Firefox is the default browser
    # This ensures scripts and applications know which browser to use
    environment.sessionVariables = lib.mkIf cfg.default {
      BROWSER = "firefox";
    };
  };
}
