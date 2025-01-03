{ lib, inputs, ... }:
{
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot = {
    # clean tmp after reboot
    tmp.cleanOnBoot = true;
    kernel.sysctl."fs.inotify.max_user_instances" = 524288;
  };

  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024;
    }
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;
  # workaround for https://github.com/NixOS/nixpkgs/issues/344963
  boot.initrd.systemd.tpm2.enable = false;
}
