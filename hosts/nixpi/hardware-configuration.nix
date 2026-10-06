{
  lib,
  pkgs,
  ...
}: {
  nixpkgs.hostPlatform = "aarch64-linux";

  # The stock NixOS Pi 4 image boots with the generic, cached AArch64 kernel.
  boot.kernelPackages = pkgs.linuxPackages;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = ["nofail"];
  };

  hardware.raspberry-pi.firmware = {
    uboot.enable = true;
  };

  boot.supportedFilesystems.zfs = lib.mkForce false;
}
