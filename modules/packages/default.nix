{
  pkgs,
  username,
  ...
}:
{

  imports = [
    ./yazi.nix
    ./anyrun.nix
  ];

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

    # troubleshooting
    hwinfo
  ];
}
