{
  config,
  username,
  lib,
  ...
}: {
  config = lib.mkIf config.michal.hyprland.enable {
    home-manager.users.${username} = {
      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = "on";
          splash = false;
          # Wallpaper is set from stylix
        };
      };
    };
  };
}
