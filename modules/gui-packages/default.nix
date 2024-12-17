{
  pkgs,
  username,
  ...
}:
{

  imports = [
    ./obs.nix
    ./fonts.nix
    ./terminal-gui.nix
    ./alacritty.nix
    ./kitty.nix
  ];

  # packages for daily needs
  environment.systemPackages = with pkgs; [
    # gui
    blueberry # Bluetooth gui
    d-spy
    kolourpaint
    nautilus
    icon-library
    dconf-editor
    qt5.qtimageformats
    yad # Dialogs
    vlc
    spotify
    rnote # drawing app for stylus
    gromit-mpx # Draw on screen

    # games
    wineWowPackages.waylandFull
    winetricks
    lutris
    parsec-bin
    moonlight-qt

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
