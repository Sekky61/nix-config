{
  hostname,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.michal.wifi;
in {
  # todo only used by nixpi, move it to configuration and delete
  options.michal.wifi = {
    enable = lib.mkEnableOption "wifi module";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wirelesstools
      wpa_supplicant
      # debug wifi
      iw
    ];

    networking = {
      hostName = hostname;
      # Add something like this to each host
      #
      # interfaces = {
      #   wlan0.useDHCP = true;
      #   eth0.useDHCP = true;
      # };

      # Enabling WIFI
      wireless = {
        enable = true;
        interfaces = ["wlan0"];
        secretsFile = config.sops.secrets.wireless.path;
        userControlled = true;
      };
    };
  };
}
