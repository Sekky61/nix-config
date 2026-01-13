{pkgs, ...}: {
  # todo rename to debug/admin
  # packages for daily needs
  environment.systemPackages = with pkgs; [
    # tools
    zip
    unzip
    exif # read metadata of pictures

    # disk/file
    file
    lsof # list open files
    libguestfs # mount virtual fs
    parted # partitions
    caligula # TUI for disk imaging
    ncdu # disk usage

    # troubleshooting
    hwinfo
    killall

    # clockify custom packaged app
    nur.repos.lucassabreu.clockify-cli

    # custom packages
    pywhispercpp
    hyprwhspr
  ];
}
