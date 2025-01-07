{ username, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/wifi.nix

    # general admin packages
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

  # Users

  users.users.${username} = {
    isNormalUser = true;
    group = "pi";
    extraGroups = [
      "wheel" # sudo
    ];
  };
  users.groups.pi = { };

  users.users.root.initialPassword = "root";

  # Rest

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@wheel" ];
  time.timeZone = "Europe/Prague";

  networking.firewall.enable = false; #todo
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  hardware = {
    bluetooth.enable = true;
  };

  system.stateVersion = lib.mkDefault "25.05";
}
