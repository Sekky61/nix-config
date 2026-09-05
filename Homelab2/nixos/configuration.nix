{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/ssh.nix
    ../../modules/overlays
    ./t3code.nix
    inputs.sops-nix.nixosModules.sops
  ];

  networking.hostName = "homelab-apps";
  time.timeZone = "Europe/Prague";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  sops = {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets."git/food-organizer-deploy-key" = {
      owner = "t3code";
      mode = "0400";
      sopsFile = ../secrets/git.yaml;
    };
  };

  networking.useDHCP = lib.mkDefault true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    8096
    3773
  ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    autoPrune.enable = true;
  };

  virtualisation.diskSize = 4096;
  fileSystems."/var/lib/homelab" = {
    device = "/dev/disk/by-label/homelab-data";
    fsType = "ext4";
    autoFormat = true;
  };

  fileSystems."/srv/media" = {
    device = "/dev/disk/by-label/homelab-media";
    fsType = "ext4";
    autoFormat = true;
  };

  services.nginx = {
    enable = true;
    virtualHosts.localhost = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
      locations."/".return = "200 'Homelab2 is running\\n'";
    };
  };

  services.jellyfin.enable = true;

  # Keep application data on a separately mounted filesystem when the VM
  # layout is defined. Do not store persistent data in the Nix store.
  systemd.tmpfiles.rules = [
    "d /var/lib/homelab 0751 root root -"
    "d /var/lib/homelab/t3code 0750 t3code t3code -"
    "z /var/lib/homelab 0751 root root -"
    "z /var/lib/homelab/t3code 0750 t3code t3code -"
  ];

  environment.systemPackages = with pkgs; [
    git
    jq
    openssh
    podman-compose
  ];

  programs.ssh.knownHosts.github = {
    hostNames = [ "github.com" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  users.users.michal = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
