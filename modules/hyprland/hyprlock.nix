{
  pkgs,
  username,
  ...
}:
let
  # TODO move to config option
  myWallpaper = "~/Pictures/wallpapers/wave.png";
in
{
  # Hyprlock is the lockscreen handling for hyprland
  # Hypridle manages automatic locking

  environment.systemPackages = with pkgs; [
    hyprlock # lock screen
    hypridle # auto lock
  ];

  michal.programs.hyprland.keybinds = [
    {
      description = "Toggle drawing to screen"; # TODO toggle off does not work (kill it with super+q)
      bind = { key = "F7"; };
      command = { dispatcher = "togglespecialworkspace"; params = "gromit"; };
    }
    {
      description = "Clear drawing";
      bind = { mods = [ "SHIFT" ]; key = "F7"; };
      command = { params = "gromit-mpx --clear"; };
    }
    {
      description = "Drawing: Undo";
      bind = { key = "F6"; };
      command = { params = "gromit-mpx --undo"; };
    }
    {
      description = "Drawing: Redo";
      bind = { mods = [ "SHIFT" ]; key = "F6"; };
      command = { params = "gromit-mpx --redo"; };
    }
  ];

  home-manager.users.${username} = _: {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 10;
          hide_cursor = true;
        };

        background = [
          {
            path = myWallpaper;
            blur_passes = 2;
            blur_size = 6;
          }
        ];

        input-field = [
          {
            size = "250, 60";
            outer_color = "rgb(#000000)";
            # inner_color = "rgb(${hexToRgb colours.bgDark})";
            font_color = "rgb(#7dc4e4)";
            placeholder_text = "";
          }
        ];

        label = [
          {
            text = "Macaroni and cheese balls";
            color = "rgba(#cad3f5, 1.0)";
            font_family = "Gabarito";
            font_size = 64;
            text_align = "center";
            halign = "center";
            valign = "center";
            position = "0, 160";
          }
          {
            text = "$TIME";
            color = "rgba(#b8c0e0, 1.0)";
            font_family = "Gabarito";
            font_size = 32;
            text_align = "center";
            halign = "center";
            valign = "center";
            position = "0, 75";
          }
        ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

        listener = [
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "brightnessctl -r"; # monitor backlight restore.
          }
          {
            timeout = 155; # 2.5min.
            on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
            on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
          }
          {
            timeout = 900; # 15min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

  };
}
