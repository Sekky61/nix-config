# https://github.com/erictossell/nixflakes/blob/main/modules/virt/libvirt.nix
{ pkgs, username, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  users.users.${username}.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    spice-protocol
    virt-viewer
    #virtio-win
    #win-spice
  ];
  programs.virt-manager.enable = true;

  # problem with home-manager variable
  # home-manager.users.${username} = {
  #   dconf.settings = {
  #     "org/virt-manager/virt-manager/connections" = {
  #       autoconnect = [ "qemu:///system" ];
  #       uris = [ "qemu:///system" ];
  #     };
  #   };
  # };
}