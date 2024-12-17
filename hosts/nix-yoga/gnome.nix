{ config
, pkgs
, ...
}: {
  # if this file is removed, some of AGS stops working. TODO
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
  };
}
