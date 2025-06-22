{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.michal.browsers.chrome;
  mkBrowserOptions = import ./options.nix;
  package = pkgs.google-chrome;
in {
  options.michal.browsers.chrome = mkBrowserOptions {
    inherit lib package;
    humanName = "google chrome";
    execName = "google-chrome";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      package
      libsForQt5.plasma-browser-integration
      (pkgs.writeShellScriptBin "google-chrome" "exec -a $0 ${package}/bin/google-chrome-stable $@")
    ];

    # Theme: `rm -fr /etc/opt/chrome/policies/managed/` helped delete old color theme.

    # programs.chromium = {
    #   # This enables policies without installing the browser. Policies take up a
    #   # negligible amount of space, so it's reasonable to have this always on.
    #   enable = true;
    #
    #   extraOpts.BrowserThemeColor = config.michal.theme.secondaryContainer;
    # };
  };
}
