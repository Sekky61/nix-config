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
  zen-package = inputs.zen-browser.packages."${pkgs.system}".default;
in {
  options.michal.browsers.zen = mkBrowserOptions {
    inherit lib;
    execName = "zen";
    package = zen-package;
  };

  config = {
    home-manager.users.${username} = {
      imports = [
        inputs.zen-browser.homeModules.default
      ];

      programs.zen-browser = {
        # Use options from firefox:
        # https://home-manager-options.extranix.com/?query=programs.firefox.&release=master
        enable = cfg.enable;
        nativeMessagingHosts = [
          pkgs.firefoxpwa
          # pkgs.kdePackages.plasma-browser-integration
        ];
      };
    };
  };
}
