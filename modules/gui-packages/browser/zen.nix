{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.michal.browsers.zen;
  mkBrowserOptions = import ./options.nix;
in {
  options.michal.browsers.zen = mkBrowserOptions {
    inherit lib;
    execName = "zen";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      inputs.zen-browser.packages."${pkgs.system}".default
    ];
  };
}
