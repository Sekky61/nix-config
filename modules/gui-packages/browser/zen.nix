/*
Zen Browser Configuration

This module configures Zen Browser, a Firefox-based browser with enhanced features.
Zen Browser is installed via an external flake input and configured through Home Manager.

Requirements:
- zen-browser flake input must be available
- Home Manager must be configured for the user

Features:
- Firefox-compatible configuration options
- PWA support through firefoxpwa
- KDE Plasma integration (commented out)
*/
{
  username,
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.michal.browsers.zen;
  mkBrowserOptions = import ./options.nix;
  # Get the Zen Browser package from the external flake input
  zen-package = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default;
in {
  options.michal.browsers.zen = mkBrowserOptions {
    inherit lib;
    execName = "zen";
    package = zen-package;
  };

  config = {
    # Zen Browser requires Home Manager configuration since it's user-specific
    home-manager.users.${username} = {
      # Import the Zen Browser Home Manager module from the external flake
      imports = [
        inputs.zen-browser.homeModules.default
      ];

      programs.zen-browser = {
        # Enable Zen Browser when the module option is enabled
        enable = cfg.enable;

        # Configure native messaging hosts for enhanced functionality
        nativeMessagingHosts = [
          # Enable Progressive Web App support
          pkgs.firefoxpwa
          # TODO: Consider enabling KDE Plasma browser integration for better desktop integration
          # pkgs.kdePackages.plasma-browser-integration
        ];
      };
    };
  };
}
