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

    # games
    wineWowPackages.waylandFull
    winetricks
    lutris

    # theming tools
    gradience
    gnome-tweaks

    # hyprland
    brightnessctl
    cliphist # clipboard history
    fuzzel # app picker
    bemoji # emoji picker
    grim
    hyprpicker
    tesseract
    imagemagick
    pavucontrol
    playerctl
    swappy
    slurp
    swww
    wayshot
    wlsunset
    wl-clipboard
    wf-recorder
    iio-sensor-proxy # pc sensors
    libinput # wayland input settings
    libinput-gestures
    xwayland # apps that do not work with wayland like spotify rn

    # tools
    blender-hip

    # troubleshooting
    showmethekey # show pressed keys
    xorg.xev

    # todo take a look at it
    nautilus-python
  ];
}
