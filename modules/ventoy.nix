{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.michal.programs.bitwarden;

  # sudo ventoy-web
  # todo: script to create ventoy usb
in
{
  options.michal.programs.ventoy = {
    enable = mkEnableOption "Enables ventoy";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ventoy-full
    ];
  };
}
