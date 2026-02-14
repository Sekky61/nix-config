{
  username,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  # Services

  michal.wifi.enable = true;
  michal.services = {
    proxy = {enable = true;};
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
      bedLampId = "37756192b7a6e872261e11b8853e4647";
      diningLampId = "ec2b6aba1eb4b926d436dad61c31807b";
      fanId = "c0396ed75d9f83cabe0daf3842a4b1b3";
    };
    n8n = {
      enable = true;
      port = 1300;
      proxy = true;
      subdomain = "n8n";
    };
  };

  michal.programs.tailscale = {
    enable = true;
    operator = username;
    systray.enable = true;
    exitNode.enable = true;
  };

  michal.programs.docker.enable = true;
  # michal.programs.podman.enable = true;

  # Users

  nixpkgs.config = {allowUnfree = true;};

  users.users.${username} = {
    isNormalUser = true;
    group = "pi";
    extraGroups = [
      "wheel" # sudo
    ];
  };
  users.groups.pi = {};

  users.users.root.initialPassword = "root";

  # Rest

  networking = {
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };

  programs.git.enable = true;
  programs.npm.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["@wheel"];
  time.timeZone = "Europe/Prague";

  networking.firewall.enable = false; # todo
  networking.firewall.allowedTCPPorts = [22 80 443];

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [pkgs.wireless-regdb];
  };

  hardware = {bluetooth.enable = true;};

  system.stateVersion = lib.mkDefault "25.05";
}
