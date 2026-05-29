{
  config,
  pkgs,
  lib,
  username,
  ...
}:
with lib; let
  graphical = config.michal.graphical.enable;
in {
  config = mkIf config.hardware.bluetooth.enable {
    services.blueman = {
      enable = graphical;
    };

    home-manager.users.${username} = {
      services.blueman-applet.enable = graphical;
    };

    environment.systemPackages = with pkgs;
      [
      ]
      ++ lib.lists.optionals graphical [
        blueman # Bluetooth gui
      ];
  };
}
