{
  pkgs,
  username,
  lib,
  ...
}:
let
  # Docs: https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper/
  # hyprctl hyprpaper listloaded

  wp = ../../assets/wallpapers;
  allWallpaperPaths = lib.filesystem.listFilesRecursive wp;
  activeWallpaper = "${wp}/spyxfamily.png";
in
{
  home-manager.users.${username} = _: {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;

        preload = [ activeWallpaper ];
        wallpaper = [
          ",${activeWallpaper}"
        ];
      };
    };
  };
}
