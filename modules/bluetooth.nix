{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  graphical = config.michal.graphical.enable;
in {
  config = mkIf config.hardware.bluetooth.enable {
    services.blueman.enable = graphical;

    environment.systemPackages = with pkgs;
      [
      ]
      ++ lib.lists.optionals graphical [
        blueberry # Bluetooth gui
      ];
  };
}
