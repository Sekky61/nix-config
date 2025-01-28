{pkgs, ...}: {
  # todo rename to debug/admin
  # packages for daily needs
  environment.systemPackages = with pkgs; [
    # tools
    killall
    zip
    unzip
    ydotool
    nmap
    openssl_3_3
    lsof
    ytdownloader
    exif # read metadata of pictures
    file
    libguestfs # mount virtual fs
    parted # partitions
    caligula # TUI for disk imaging
    dig
    ncdu # disk usage

    # troubleshooting
    hwinfo
  ];
}
