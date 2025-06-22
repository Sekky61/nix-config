{
  config,
  pkgs,
  lib,
  username,
  ...
}:
with lib; let
  launcher = pkgs.writeShellScriptBin "hypr" ''
    #!/${pkgs.bash}/bin/bash

    export WLR_NO_HARDWARE_CURSORS=1
    export _JAVA_AWT_WM_NONREPARENTING=1

    exec ${hyprland_pkg}/bin/Hyprland
  '';

  browser = config.environment.sessionVariables.BROWSER;
  defaultTerminal = config.michal.environment.terminal;

  myMonitors = {
    laptop = "Samsung Display Corp. 0x4193";
    gigabyte = "GIGA-BYTE TECHNOLOGY CO. LTD. GIGABYTE G24F 22080B010444";
  };

  rounding = 5; # px
in {
  imports = [
    ./keybinds.nix
    ./gromit.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./auth.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      # launcher
      nwg-displays # gui for monitors, wayland
      hyprshot

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
      swww # wallpaper
      wayshot
      wlsunset
      wl-clipboard
      wf-recorder
      libinput # wayland input settings
      libinput-gestures
      xwayland # apps that do not work with wayland like spotify rn
    ];

    programs.hyprland.enable = true; # enables xdg-desktop-portal-hyprland

    programs.xwayland.enable = true;

    programs.iio-hyprland.enable = true; # screen rotation, todo does not work

    home-manager.users.${username} = _: {
      # Optional, hint Electron apps to use Wayland:
      home.sessionVariables.NIXOS_OZONE_WL = "1";

      xdg.desktopEntries."org.gnome.Settings" = {
        name = "Settings";
        comment = "Gnome Control Center";
        icon = "org.gnome.Settings";
        exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
        categories = ["X-Preferences"];
        terminal = false;
      };

      wayland.windowManager.hyprland = {
        enable = true;

        plugins = with pkgs; [
          # hyprlandPlugins.<plugin>
        ];

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
            # todo generalize
            "desc:${myMonitors.laptop},2880x1800@90.0,0x0,1.5,transform,0" # Yoga laptop screen
            "desc:${myMonitors.gigabyte},1920x1080@165.0,1920x0,1" # desk monitor. scale 1 is big but works best
            ",preferred,auto,1" # auto
          ];
          exec-once = [
            # system tray
            "ags run"
            # wallpaper
            "ydotoold"
            "swww kill; swww init"
            # hw sensors (screen rotation)
            "iio-hyprland eDP-1"
            # paste history init
            "wl-paste --type text --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
            # cursor todo
            "hyprctl setcursor Bibata-Modern-Classic 24"
            # launch programs
            "[workspace 1 silent] ${browser}"
            "[workspace 2 silent] ${defaultTerminal}"
          ];
          general = {
            gaps_in = 2;
            gaps_out = 3;
            gaps_workspaces = 50;
            layout = "dwindle";
            resize_on_border = true; # click and drag on border to resize
            border_size = 1;
            #"col.active_border" = "rgba(38bdf8ee)";
            #"col.inactive_border" = "rgba(0369a1cc)";
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
            kb_options = "grp:alt_shift_toggle"; # todo this might interfere with alt shift binds
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
              #color = "rgba(0000001A)";
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
          bind = [
            # todo move rest of keybinds

            # "Super, S, togglespecialworkspace,"
            # "Control+Super, S, togglespecialworkspace,"
            "Alt, Tab, cyclenext"
            "Alt, Tab, bringactivetotop,"
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
          bindle = [
            "Alt, I, exec, ydotool key 103:1 103:0 "
            "Alt, K, exec, ydotool key 108:1 108:0"
            "Alt, J, exec, ydotool key 105:1 105:0"
            "Alt, L, exec, ydotool key 106:1 106:0"
          ];
          bindr = [
            "Control+Super, R, exec, killall ags .ags-wrapped ydotool; ags &"
            "Control+Super+Alt, R, exec, hyprctl reload; killall ags ydotool; ags &"
          ];
          windowrule = [
            "noblur, title:.*" # Disables blur for windows. Substantially improves performance.
            "float, title:^(steam)$"
            "pin, title:^(showmethekey-gtk)$"
            "float,title:^(Open File)(.*)$"
            "float,title:^(Select a File)(.*)$"
            "float,title:^(Choose wallpaper)(.*)$"
            "float,title:^(Open Folder)(.*)$"
            "float,title:^(Save As)(.*)$"
            "float,title:^(Library)(.*)$ "
          ];
          windowrulev2 = ["tile,class:(wpsoffice)"];
          layerrule = [
            "xray 1, .*"
            "noanim, selection"
            "noanim, overview"
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
          # source = [ # todo
          #   "./hyprland/colors.conf"
          # ];
        };
      };
    };
  };
}
