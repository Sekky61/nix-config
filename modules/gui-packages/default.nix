{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./obs.nix
    ./fonts.nix
    ./kitty.nix
    ./remote-desktop.nix
    ./ags
    ./stt.nix
    ./fuzzel.nix
    ./theme.nix

    # With options
    ./browser
    ./steam.nix
    ./terminal-emulator
  ];

  # bluetooth
  services.blueman.enable = true;

  # packages for daily needs
  environment.systemPackages = with pkgs; [
    # gui
    blueberry # Bluetooth gui
    d-spy
    # paint
    # kolourpaint
    nautilus
    icon-library
    dconf-editor
    qt5.qtimageformats
    yad # Dialogs
    vlc
    spotify
    rnote # drawing app for stylus

    # Notifications
    libnotify #(notify-send)

    # games
    wineWowPackages.waylandFull
    winetricks
    lutris
    parsec-bin

    discord

    # theming tools
    gradience
    gnome-tweaks

    # tools
    blender-hip

    # troubleshooting
    # keywords: debug keys print
    showmethekey # show pressed keys
    xorg.xev

    # todo take a look at it
    nautilus-python
  ];
}
