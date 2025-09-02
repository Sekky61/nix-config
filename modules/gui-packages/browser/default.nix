/*
  Browser Module

  This module provides a unified interface for configuring multiple web browsers
  in the NixOS system. It supports Chrome, Firefox, and Zen Browser with consistent
  configuration options.

  Features:
  - Install and configure multiple browsers simultaneously
  - Set a default browser that integrates with system MIME types
  - Automatic desktop file associations for web protocols
  - Home Manager integration for user-specific browser settings

  Configuration:
  - michal.browsers.<browser>.enable: Install and enable the browser
  - michal.browsers.<browser>.default: Set as the system default browser
  - Only one browser can be marked as default at a time

  Example:
  {
    michal.browsers = {
      firefox.enable = true;
      firefox.default = true;
      chrome.enable = true;
    };
  }
*/
{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.browsers;
  browsers = cfg;

  defaultBrowsers = lib.attrValues (
    lib.filterAttrs (name: value: value ? default && value.default) browsers
  );
  defaultBrowser = lib.michal.optionalHead defaultBrowsers;
  hasDefaultBrowser = defaultBrowser != null;
in {
  config = mkIf hasDefaultBrowser {
    environment.sessionVariables = {
      BROWSER = defaultBrowser.name;
    };

    home-manager.users.${username} = {
      # Verify with `xdg-mime query default x-scheme-handler/http`
      xdg.mimeApps = {
        defaultApplications = let
          browser = defaultBrowser.desktopFileName;
        in {
          "default-web-browser" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "application/xhtml+xml" = browser;
          "text/html" = browser;
          "application/pdf" = browser;
        };
      };
    };

    assertions = [
      {
        assertion = lib.length defaultBrowsers <= 1;
        message = "You have more than one default browsers: ${lib.concatStringsSep " " (lib.map (br: br.name) defaultBrowsers)}";
      }
    ];
  };

  imports = [
    ./chrome.nix
    ./firefox.nix
    ./zen.nix
  ];
}
