/*
  Google Chrome Browser Configuration

  This module configures Google Chrome with system integration and theming support.
  Chrome requires special handling due to its executable naming and desktop integration.
*/
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.michal.browsers.chrome;
  mkBrowserOptions = import ./options.nix;
  # Use the stable Google Chrome package
  package = pkgs.google-chrome;
in {
  options.michal.browsers.chrome = mkBrowserOptions {
    inherit lib package;
    humanName = "google chrome";
    execName = "google-chrome";
    # todo desktopFileName not working
  };

  config = lib.mkIf cfg.enable {
    # Install Chrome and create a wrapper script for consistent executable name
    environment.systemPackages = with pkgs; [
      package
      # TODO: Consider enabling KDE Plasma browser integration for better desktop integration
      # kdePackages.plasma-browser-integration

      # Create a wrapper script that ensures consistent process naming
      # Chrome's actual binary is google-chrome-stable, but we want google-chrome to work
      (pkgs.writeShellScriptBin "google-chrome" "exec -a $0 ${package}/bin/google-chrome-stable $@")
    ];

    # Note: Chrome theme configuration
    # If you need to reset Chrome's color theme, you can remove:
    # rm -fr /etc/opt/chrome/policies/managed/
    # This directory contains managed policies that might override user theme preferences.

    # Alternative: Use NixOS chromium module for theme integration
    # This approach would allow setting the browser theme color from the system theme
    # programs.chromium = {
    #   # This enables policies without installing the browser. Policies take up a
    #   # negligible amount of space, so it's reasonable to have this always on.
    #   enable = true;
    #
    #   # Set browser theme color to match system theme
    #   extraOpts.BrowserThemeColor = config.michal.theme.secondaryContainer;
    # };
  };
}
