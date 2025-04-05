{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    # ./../../../hosts/common/modules/nix/nixos.nix
    # ./../../../home/konrad/common/options/ssh-keys.nix
    # ./../../../home/konrad/common/modules/base/ssh-keys.nix
  ];

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    # we provide external instance
    config = lib.mkForce {};
  };

  networking = {
    hostName = "nix-installer-iso";
    networkmanager.enable = true;
    wireless.enable = false;
  };

  # needed for updates for now
  users.users.root.openssh.authorizedKeys.keys = config.michal.sshKeys.personal.keys;

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
