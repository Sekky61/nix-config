{
  pkgs,
  lib,
  modulesPath,
  username,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    # we provide external instance
    config = lib.mkForce {};
  };

  networking = {
    hostName = username;
    networkmanager.enable = true;
    wireless.enable = false;
  };

  users.groups.${username} = {};
  users.users.${username} = {
    group = username;
    isSystemUser = true;
  };

  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };
}
