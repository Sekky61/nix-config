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
