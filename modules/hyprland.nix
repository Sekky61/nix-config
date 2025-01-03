{
  inputs,
  pkgs,
  username,
  ...
}:
let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
  plugins = inputs.hyprland-plugins.packages.${pkgs.system};

  launcher = pkgs.writeShellScriptBin "hypr" ''
    #!/${pkgs.bash}/bin/bash

    export WLR_NO_HARDWARE_CURSORS=1
    export _JAVA_AWT_WM_NONREPARENTING=1

    exec ${hyprland}/bin/Hyprland
  '';

  myMonitors = {
    laptop = "Samsung Display Corp. 0x4193";
    gigabyte = "GIGA-BYTE TECHNOLOGY CO. LTD. GIGABYTE G24F 22080B010444";
  };

  myWallpaper = "~/Pictures/wallpapers/wave.png";

  rounding = 5; # px
in
{
  environment.systemPackages = with pkgs; [
    launcher
    nwg-displays # gui for monitors, wayland
    hyprlock # lock screen
    hypridle # auto lock
    hyprshot

    fuzzel # app picker
    bemoji # emoji picker
    grim
    slurp
    hyprpicker # color picker

    # hyprland
    brightnessctl
    cliphist # clipboard history
    tesseract # OCR
    imagemagick
    pavucontrol
    playerctl
    swappy
    swww
    wayshot
    wlsunset
    wl-clipboard
    wf-recorder
    iio-sensor-proxy # pc sensors
    libinput # wayland input settings
    libinput-gestures
    xwayland # apps that do not work with wayland like spotify rn

  ];

  home-manager.users.${username} = _: {
    xdg.desktopEntries."org.gnome.Settings" = {
      name = "Settings";
      comment = "Gnome Control Center";
      icon = "org.gnome.Settings";
      exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
      categories = [ "X-Preferences" ];
      terminal = false;
    };

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

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        env = [
          "QT_QPA_PLATFORM, wayland"
          "QT_QPA_PLATFORMTHEME, qt5ct"
          "QT_STYLE_OVERRIDE,kvantum"
          "GDK_SCALE, 2"
          "XCURSOR_SIZE, 32"
          "WLR_NO_HARDWARE_CURSORS, 1"
        ];
        monitor = [
          "desc:${myMonitors.laptop},2880x1800@90.0,0x0,1.5" # Yoga laptop screen
          "desc:${myMonitors.gigabyte},1920x1080@165.0,1920x0,1" # desk monitor. scale 1 is big but works best
          ",preferred,auto,1" # auto
        ];
        "exec-once" = [
          # system tray
          "ags"
          # wallpaper
          "swww kill; swww init"
          # go to sleep after inactivity
          "hypridle"
          # hw sensors (screen rotation)
          "iio-hyprland"
          # paste history
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          # cursor
          "hyprctl setcursor Bibata-Modern-Classic 24"
          # kdeconnect
          "kdeconnect-indicator"
          # launch Chrome
          "[workspace 1 silent] google-chrome-stable"
        ];
        general = {
          gaps_in = 2;
          gaps_out = 3;
          gaps_workspaces = 50;
          layout = "dwindle";
          resize_on_border = true; # click and drag on border to resize
          border_size = 1;
          "col.active_border" = "rgba(38bdf8ee)";
          "col.inactive_border" = "rgba(0369a1cc)";
        };
        dwindle = {
          preserve_split = true;
          smart_resizing = false;
        };
        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
          workspace_swipe_distance = 700;
          workspace_swipe_touch = true;

          workspace_swipe_cancel_ratio = 0.2;
          workspace_swipe_min_speed_to_force = 5;
          workspace_swipe_direction_lock = true;
          workspace_swipe_direction_lock_threshold = 10;
          workspace_swipe_create_new = true;
        };
        binds = {
          scroll_event_delay = 0;
        };
        input = {
          sensitivity = 0.2; # -1 to 1
          # Keyboard: Add a layout and uncomment kb_options for Win+Space switching shortcut
          kb_layout = "us,cz";
          kb_options = "grp:alt_shift_toggle";
          numlock_by_default = true;
          repeat_delay = 250;
          repeat_rate = 35;

          touchpad = {
            natural_scroll = true;
            disable_while_typing = false;
            clickfinger_behavior = true;
            scroll_factor = 0.5;
          };

          special_fallthrough = true; # only in new hyprland versions. but they're hella fucked
          follow_mouse = 1;
        };
        decoration = {
          rounding = rounding;

          blur = {
            enabled = true;
            xray = true;
            special = false;
            new_optimizations = true;
            size = 5;
            passes = 4;
            brightness = 1;
            noise = 1.0e-2;
            contrast = 1;
          };
          # Shadow
          shadow = {
            enabled = true;
            color = "rgba(0000001A)";
            offset = "0 2";
            range = 20;
            render_power = 2;
            ignore_window = true;
          };

          # Dim
          dim_inactive = true;
          dim_strength = 0.1;
          dim_special = 0;
        };
        animations = {
          enabled = true;
          bezier = [
            "md3_decel, 0.05, 0.7, 0.1, 1"
            "md3_accel, 0.3, 0, 0.8, 0.15"
            "overshot, 0.05, 0.9, 0.1, 1.1"
            "crazyshot, 0.1, 1.5, 0.76, 0.92"
            "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
            "fluent_decel, 0.1, 1, 0, 1"
            "easeInOutCirc, 0.85, 0, 0.15, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutExpo, 0.16, 1, 0.3, 1"
          ];
          animation = [
            "windows, 1, 3, md3_decel, popin 60%"
            "border, 1, 10, default"
            "fade, 1, 2.5, md3_decel"
            # "workspaces, 1, 3.5, md3_decel, slide"
            "workspaces, 1, 7, fluent_decel, slide"
            # "workspaces, 1, 7, fluent_decel, slidefade 15%"
            # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
            "specialWorkspace, 1, 3, md3_decel, slidevert"
          ];
        };
        misc = {
          vfr = 1;
          vrr = 1;

          key_press_enables_dpms = true; # Should wake up screen
          mouse_move_enables_dpms = true;

          # layers_hog_mouse_focus = true;
          focus_on_activate = true;
          animate_manual_resizes = false;
          animate_mouse_windowdragging = false;
          # Swallowing: replacing graphical window with the spawining terminal
          enable_swallow = false;
          swallow_regex = "(foot|kitty|allacritty|Alacritty)";

          disable_hyprland_logo = true;
          new_window_takes_over_fullscreen = 2;
        };
        xwayland = {
          force_zero_scaling = true;
        };
        bind =
          let
            ss_flags = {
              monitor = "-m output";
              region = "-m region";
              window = "-m window";
              clipboard = "--clipboard-only"; # default: both storage and clipboard
              freeze = "--freeze";
              stdout = "--raw";
            };
            screen = flagArr: toString ([ "hyprshot" ] ++ flagArr);
            ss_region_stdout = screen (
              with ss_flags;
              [
                region
                stdout
              ]
            );
            ss_region_clipboard = screen (
              with ss_flags;
              [
                region
                clipboard
              ]
            );
          in
          [
            # Launch
            "Super, Space, exec, ags -t 'overview'" # Launcher
            "Super, Return, exec, alacritty"
            "Super, W, exec, google-chrome-stable"
            "Super, C, exec, code --password-store=gnome"
            "Super, E, exec, nautilus --new-window"
            "Super+Alt, E, exec, alacritty -e yazi"
            # System
            "Super, Q, killactive, "
            "Shift+Super+Alt, Q, exec, hyprctl kill" # select a window to kill
            "Control+Alt, Delete, exec, ags -t 'session'" # session menu (logout, restart, shutdown)
            "Control+Shift+Alt, Delete, exec, pkill wlogout || wlogout -p layer-shell"
            "Control+Shift+Alt+Super, Delete, exec, systemctl poweroff"
            # Open
            ''Super, I, exec, XDG_CURRENT_DESKTOP="gnome" gnome-control-center'' # Settings
            "Control+Super, V, exec, pavucontrol" # sound mixer
            "Control+Shift, Escape, exec, gnome-system-monitor" # system resources
            "Super, Period, exec, bemoji" # emoji
            "Super+Alt, Space, togglefloating, "
            "Super, K, exec, ags -t 'osk'" # virtual keyboard
            # screenshot
            ",Print,exec, ${ss_region_clipboard}" # May not work
            "Super, S, exec, ${ss_region_clipboard}"
            "Super+Alt, S, exec, ${ss_region_stdout} | swappy -f -"
            "Super+Shift, S, exec, ${ss_region_stdout} | tesseract stdin stdout | wl-copy"
            # Record
            "Super+Alt, R, exec, record"
            "Control+Alt, R, exec, record --fullscreen"
            "Super+Shift+Alt, R, exec, record --fullscreen-sound"
            "Super+Shift, C, exec, hyprpicker -a" # color picker
            "Super, V, exec, pkill fuzzel || cliphist list | fuzzel --dmenu | cliphist decode | wl-copy" # clipboard history
            # Lock
            "Super, L, exec, hyprlock"
            "Super+Shift, L, exec, hyprlock"
            "Control+Super, Slash, exec, pkill anyrun || anyrun" # todo crashes after one letter
            "Control+Super, T, exec, ~/.config/ags/scripts/color_generation/switchwall.sh"
            "Control+Super, R, exec, killall ags ydotool; ags -b hypr" # reset ags
            "Super, Tab, exec, ags -t 'overview'" # todo broken
            "Super, Slash, exec, ags -t 'cheatsheet'"
            # Open side menu
            "Super, B, exec, ags -t 'sideleft'"
            "Super, A, exec, ags -t 'sideleft'"
            "Super, O, exec, ags -t 'sideleft'"
            "Super, N, exec, ags -t 'sideright'"
            # gromit-mpx
            ", F7, togglespecialworkspace, gromit"
            "SHIFT , F7, exec, gromit-mpx --clear"
            ", F6, exec, gromit-mpx --undo"
            "SHIFT , F6, exec, gromit-mpx --redo"
            # Rest
            "Super, M, exec, ags run-js 'openMusicControls.value = !openMusicControls.value;'"
            "Super, Comma, exec, ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'" # show color scheme
            "Super+Alt, f12, exec, notify-send 'Test notification' 'This is a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!' -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'"
            "Super+Alt, Equal, exec, notify-send 'Urgent notification' 'Ah hell no' -u critical -a 'Hyprland keybind'"
            "Super+Shift, left, movewindow, l"
            "Super+Shift, right, movewindow, r"
            "Super+Shift, up, movewindow, u"
            "Super+Shift, down, movewindow, d"
            "Super, left, movefocus, l"
            "Super, right, movefocus, r"
            "Super, up, movefocus, u"
            "Super, down, movefocus, d"
            "Super, BracketLeft, movefocus, l"
            "Super, BracketRight, movefocus, r"
            "Control+Super, right, workspace, +1"
            "Control+Super, left, workspace, -1"
            "Control+Super, BracketLeft, workspace, -1"
            "Control+Super, BracketRight, workspace, +1"
            "Control+Super, up, workspace, -5"
            "Control+Super, down, workspace, +5"
            "Super, Page_Down, workspace, +1"
            "Super, Page_Up, workspace, -1"
            "Control+Super, Page_Down, workspace, +1"
            "Control+Super, Page_Up, workspace, -1"
            "Super+Alt, Page_Down, movetoworkspace, +1"
            "Super+Alt, Page_Up, movetoworkspace, -1"
            "Super+Shift, Page_Down, movetoworkspace, +1"
            "Super+Shift, Page_Up, movetoworkspace, -1"
            "Control+Super+Shift, Right, movetoworkspace, +1"
            "Control+Super+Shift, Left, movetoworkspace, -1"
            "Super+Shift, mouse_down, movetoworkspace, -1"
            "Super+Shift, mouse_up, movetoworkspace, +1"
            "Super+Alt, mouse_down, movetoworkspace, -1"
            "Super+Alt, mouse_up, movetoworkspace, +1"
            "Super, F, fullscreen, 0" # full screen without topbar
            "Super, D, fullscreen, 1" # full screen
            "Super_Alt, F, fullscreenstate, -1 2"
            "Super, 1, workspace, 1"
            "Super, 2, workspace, 2"
            "Super, 3, workspace, 3"
            "Super, 4, workspace, 4"
            "Super, 5, workspace, 5"
            "Super, 6, workspace, 6"
            "Super, 7, workspace, 7"
            "Super, 8, workspace, 8"
            "Super, 9, workspace, 9"
            "Super, 0, workspace, 10"
            # "Super, S, togglespecialworkspace,"
            # "Control+Super, S, togglespecialworkspace,"
            "Alt, Tab, cyclenext"
            "Alt, Tab, bringactivetotop,"
            "Super+Shift, 1, movetoworkspacesilent, 1"
            "Super+Shift, 2, movetoworkspacesilent, 2"
            "Super+Shift, 3, movetoworkspacesilent, 3"
            "Super+Shift, 4, movetoworkspacesilent, 4"
            "Super+Shift, 5, movetoworkspacesilent, 5"
            "Super+Shift, 6, movetoworkspacesilent, 6"
            "Super+Shift, 7, movetoworkspacesilent, 7"
            "Super+Shift, 8, movetoworkspacesilent, 8"
            "Super+Shift, 9, movetoworkspacesilent, 9"
            "Super+Shift, 0, movetoworkspacesilent, 10"
            "Control+Shift+Super, Up, movetoworkspacesilent, special"
            "Super, m, movecurrentworkspacetomonitor, +1"
            # "Super+Shift, S, movetoworkspacesilent, special"
            "Super, mouse_up, workspace, +1"
            "Super, mouse_down, workspace, -1"
            "Control+Super, mouse_up, workspace, +1"
            "bind = Control+Super, mouse_down, workspace, -1"
          ];
        bindm = [
          "Super, mouse:272, movewindow" # left click to move window
          "Super, Z, movewindow"
          "Super, mouse:273, resizewindow" # right click to resize window
        ];
        bindl = [
          ",XF86AudioMute, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"
          "Super+Shift,M, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"
          ''Super+Shift, N, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`''
          '',XF86AudioNext, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`''
          "Super+Shift, B, exec, playerctl previous"
          "Super+Shift, P, exec, playerctl play-pause"
          ",XF86AudioPlay, exec, playerctl play-pause"
          "Super+Shift, L, exec, sleep 0.1 && systemctl suspend"
          ", XF86AudioMute, exec, ags run-js 'indicator.popup(1);'"
          "Super+Shift,M,   exec, ags run-js 'indicator.popup(1);'"
        ];
        bindle = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86MonBrightnessUp, exec, ags run-js 'brightness.screen_value += 0.05;indicator.popup(1);'"
          ",XF86MonBrightnessDown, exec, ags run-js 'brightness.screen_value -= 0.05;indicator.popup(1);'"
          ",XF86AudioRaiseVolume, exec, ags run-js 'indicator.popup(1);'"
          ",XF86AudioLowerVolume, exec, ags run-js 'indicator.popup(1);'"
          ",XF86MonBrightnessUp, exec, ags run-js 'indicator.popup(1);'"
          ",XF86MonBrightnessDown, exec, ags run-js 'indicator.popup(1);'"
          "Alt, I, exec, ydotool key 103:1 103:0 "
          "Alt, K, exec, ydotool key 108:1 108:0"
          "Alt, J, exec, ydotool key 105:1 105:0"
          "Alt, L, exec, ydotool key 106:1 106:0"
        ];
        bindr = [
          "Control+Super, R, exec, killall ags .ags-wrapped ydotool; ags &"
          "Control+Super+Alt, R, exec, hyprctl reload; killall ags ydotool; ags &"
        ];
        # bindir = [ "Super, Super_L, exec, ags -t 'overview'" ]; # Launcher
        binde = [
          "Super, Minus, splitratio, -0.1"
          "Super, Equal, splitratio, 0.1"
          "Super, Semicolon, splitratio, -0.1"
          "Super, Apostrophe, splitratio, 0.1"
        ];
        windowrule = [
          "noblur,.*" # Disables blur for windows. Substantially improves performance.
          "float, ^(steam)$"
          "pin, ^(showmethekey-gtk)$"
          "float,title:^(Open File)(.*)$"
          "float,title:^(Select a File)(.*)$"
          "float,title:^(Choose wallpaper)(.*)$"
          "float,title:^(Open Folder)(.*)$"
          "float,title:^(Save As)(.*)$"
          "float,title:^(Library)(.*)$ "
          # Gromit-MPX
          "noblur, ^(Gromit-mpx)$"
          "opacity 1 override, 1 override, ^(Gromit-mpx)$"
          "noshadow, ^(Gromit-mpx)$"
          "size 100% 100%, ^(Gromit-mpx)$"
        ];
        workspace = [
          "special:gromit, gapsin:0, gapsout:0, on-created-empty: gromit-mpx -a"
        ];
        windowrulev2 = [ "tile,class:(wpsoffice)" ];
        layerrule = [
          "xray 1, .*"
          "noanim, selection"
          "noanim, overview"
          "noanim, anyrun"
          "blur, eww"
          "ignorealpha 0.8, eww"
          "noanim, noanim"
          "blur, noanim"
          "blur, gtk-layer-shell"
          "ignorezero, gtk-layer-shell"
          "blur, launcher"
          "ignorealpha 0.5, launcher"
          "blur, notifications"
          "ignorealpha 0.69, notifications"
          "blur, session"
          "noanim, sideright"
          "noanim, sideleft"
        ];
        source = [
          "./hyprland/colors.conf"
        ];
      };
    };

  };
}
