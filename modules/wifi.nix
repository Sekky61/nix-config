{ hostname, pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    wirelesstools
    wpa_supplicant
  ];

  networking = {
    hostName = hostname;
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };

    # Enabling WIFI
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      secretsFile = config.sops.secrets.wireless.path;
      networks = {
        "Smart Toilet" = {
          pskRaw = "ext:smart_toilet_psk";
        };
      };
    };
  };
}
