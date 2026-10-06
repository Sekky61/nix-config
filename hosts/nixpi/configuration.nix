{
  inputs,
  pkgs,
  ...
}: let
  adminKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkCgOhmEum22iwht2rfJxWnbNCVbd0gWOPXdYHO1vPU michal-nix-key";
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  networking.hostName = "nixpi";
  networking.useDHCP = true;
  networking.wireless = {
    enable = true;
    interfaces = ["wlan0"];
    secretsFile = "/var/lib/nixpi-wifi.secrets";
    networks."Smart Toilet".pskRaw = "ext:psk_smart_toilet";
    extraConfig = "country=CZ";
  };
  time.timeZone = "Europe/Prague";

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users.pi = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [adminKey];
  };
  users.users.root.openssh.authorizedKeys.keys = [adminKey];
  security.sudo.wheelNeedsPassword = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.pi = import ../../homes/pi;
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "prohibit-password";
  };
  networking.firewall.allowedTCPPorts = [22];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = ["--operator=pi"];
  };

  systemd.services.t3code = {
    description = "T3 Code";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target" "tailscaled.service"];
    wants = ["network-online.target" "tailscaled.service"];
    path = [pkgs.git pkgs.gh pkgs.openssh pkgs.michal-unstable.codex];
    serviceConfig = {
      User = "pi";
      WorkingDirectory = "/home/pi";
      ExecStart = "${pkgs.michal-unstable.t3code}/bin/t3 serve --host 127.0.0.1 --port 3773 --tailscale-serve";
      Restart = "on-failure";
    };
  };

  nixpkgs.overlays = [
    (final: _: {
      michal-unstable = import inputs.nixpkgs-spicy {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
    })
  ];
  environment.systemPackages = [
    pkgs.git
    pkgs.gh
    pkgs.michal-unstable.codex
    pkgs.michal-unstable.t3code
  ];

  system.stateVersion = "25.11";
}
