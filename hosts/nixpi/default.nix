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

  users.users.${username} = {
    isNormalUser = true;
    password = "password";
    group = "pi";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkCgOhmEum22iwht2rfJxWnbNCVbd0gWOPXdYHO1vPU majer"
    ];
  };
  users.groups.pi = { };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@wheel" ];

  # konrad.services.autoupgrade = {
  #   enable = true;
  # };

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = true;
    settings.PermitRootLogin = "yes";
    settings.X11Forwarding = true;
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
