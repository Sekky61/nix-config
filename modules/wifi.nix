{ hostname, pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    wirelesstools
    wpa_supplicant
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
      interfaces = [ "wlan0" ];
      secretsFile = config.sops.secrets.wireless.path;
      userControlled.enable = true;
      networks = {
        "Smart Toilet" = {
          pskRaw = "ext:smart_toilet_psk";
        };
        "WiFi Mission 3" = {
          pskRaw = "ext:mission_3_psk";
        };
        "Regiojet - zluty" = {};
      };
    };
  };
}
