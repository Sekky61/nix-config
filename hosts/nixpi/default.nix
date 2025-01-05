{ hostname, username, lib, pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    wirelesstools
    wpa_supplicant
  ];

  # Services

  michal.services = {
    proxy = {
      enable = true;
    };
    homepage = {
      enable = true;
      port = 1270;
      proxy = true;
      subdomain = "homepage";
    };
    adguardhome = {
      enable = true;
      port = 1280;
      proxy = true;
      subdomain = "adguard";
    };
    home-assistant = {
      enable = true;
      port = 1290;
      proxy = true;
      subdomain = "homeassistant";
    };
  };

  # Rest

  users.users.${username} = {
    isNormalUser = true;
    group = "pi";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkCgOhmEum22iwht2rfJxWnbNCVbd0gWOPXdYHO1vPU majer"
    ];
    extraGroups = [
      "wheel"
    ];
  };
  users.groups.pi = { };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@wheel" ];

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  time.timeZone = "Europe/Prague";
  users.users.root.initialPassword = "root";
  networking = {
    hostName = hostname;
    useDHCP = false;
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
  hardware = {
    bluetooth.enable = true;
  };

  system.stateVersion = lib.mkDefault "25.05";
}
