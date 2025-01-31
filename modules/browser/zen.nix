{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.programs.zen;
in {
  options.michal.programs.zen = {
    enable = mkEnableOption "zen browser";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.zen-browser.packages."${pkgs.system}".default
    ];
  };
}
