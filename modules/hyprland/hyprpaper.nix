{
  pkgs,
  username,
  lib,
  ...
}:
{
  home-manager.users.${username} = _: {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        # Wallpaper is set from stylix
      };
    };
  };
}
