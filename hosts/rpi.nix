{
  pkgs,
  lib,
  username,
  hostname,
  ...
}: {
  # bcm2711 for rpi 3, 3+, 4, zero 2 w
  # bcm2712 for rpi 5
  # See the docs at:
  # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration

  environment.systemPackages = with pkgs; [
    vim
    wget
    wirelesstools
    wpa_supplicant
  ];

  # WiFi
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [pkgs.wireless-regdb];
  };

  users.users.${username} = {
    isNormalUser = true;
    password = "password";
    group = "pi";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkCgOhmEum22iwht2rfJxWnbNCVbd0gWOPXdYHO1vPU majer"
    ];
  };
  users.groups.pi = {};

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["@wheel"];

  networking.firewall.allowedTCPPorts = [22 80 443];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = true;
    settings.PermitRootLogin = "yes";
    settings.X11Forwarding = true;
  };

  raspberry-pi-nix.board = "bcm2711";
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
    wireless.enable = true;
    wireless.interfaces = ["wlan0"];
  };
  hardware = {
    bluetooth.enable = true;
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            # enable autoprobing of bluetooth driver
            # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
            krnbt = {
              enable = true;
              value = "on";
            };
          };
        };
      };
    };
  };

  system.stateVersion = "24.11";
}
