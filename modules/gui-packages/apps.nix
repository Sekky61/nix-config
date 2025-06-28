{
  config,
  pkgs,
  username,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.graphical;
in {
  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = with pkgs; [
        vlc
        spotify
        discord

        # Stylus drawing app
        rnote

        # tools
        blender-hip
      ];
    };

    # packages for daily needs
    environment.systemPackages = with pkgs; [
      # gui utils, debugging. Keywords: debug keys print
      d-spy
      yad # Dialogs
      libnotify # notify-send
      showmethekey # show pressed keys
      xorg.xev

      # theming tools
      gradience
      gnome-tweaks

      # paint
      # kolourpaint
      icon-library
      dconf-editor
      qt5.qtimageformats

      # games
      wineWowPackages.waylandFull
      winetricks
      lutris
      parsec-bin

      # Nautilus file manager
      nautilus
      nautilus-open-any-terminal
      # todo take a look at it
      nautilus-python
    ];

    # Nautilus, continued
    environment = {
      sessionVariables = {
        NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
      };

      pathsToLink = [
        "/share/nautilus-python/extensions"
      ];
    };
  };
}
