{
  config,
  pkgs,
  ...
}: {
  environment = {
    sessionVariables = {
      NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
    };

    pathsToLink = [
      "/share/nautilus-python/extensions"
    ];

    systemPackages = with pkgs; [
      gnome-extension-manager
      nautilus-open-any-terminal
      morewaita-icon-theme
      bibata-cursors
      rubik
      lexend
      twitter-color-emoji
    ];

    gnome.excludePackages =
      (with pkgs; [
        gedit # text editor
        gnome-photos
        gnome-tour
        gnome-connections
        snapshot
        cheese # webcam tool
        evince # document viewer
        totem # video player
        yelp # Help view
      ])
      ++ (with pkgs.gnome; [
        gnome-music
        # gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        gnome-contacts
        gnome-initial-setup
        gnome-shell-extensions
        gnome-maps
        # gnome-font-viewer
      ]);
  };
}
