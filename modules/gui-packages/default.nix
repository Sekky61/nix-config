{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./obs.nix
    ./fonts.nix
    ./terminal-gui.nix
    ./alacritty.nix
    ./kitty.nix
    ./anyrun.nix
    ./remote-desktop.nix
    ./ags
    ./stt.nix

    ./browser/chrome.nix
    ./browser/firefox.nix
    ./browser/zen.nix

    # With options
    ./steam.nix
  ];

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
