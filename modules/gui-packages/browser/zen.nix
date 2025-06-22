{
  config,
  lib,
  inputs,
  pkgs,
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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      zen-package
    ];
  };
}
