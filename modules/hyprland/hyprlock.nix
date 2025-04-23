{
  pkgs,
  username,
  config,
  ...
}: let
  myWallpaper = builtins.toPath config.stylix.image;
in {
  # Hyprlock is the lockscreen handling for hyprland
  # Hypridle manages automatic locking

  home-manager.users.${username} = {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 10; # Unlock without password up to x seconds after lock
          hide_cursor = true;
        };
        background = [
          {
            path = myWallpaper;
            blur_passes = 2;
            blur_size = 6;
            contrast = 1;
            brightness = 0.5;
            vibrancy = 0.2;
            vibrancy_darkness = 0.2;
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
            text = "@grok, is this true?";
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
            timeout = 180; # 3min.
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "brightnessctl -r"; # monitor backlight restore.
          }
          {
            timeout = 180; # 3min.
            on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
            on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
          }
          {
            timeout = 300; # 5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 900; # 15min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      settings = {
        exec-once = ["hypridle"];
      };
    };
  };
}
