{
  lib,
  username,
  config,
  pkgs,
  ...
}:
with lib; let
  # Define all binds for Hyprland
  #
  # - SUPER is the Win key
  cfg = config.michal.programs.hyprland.keybinds;
  defaultTerminal = config.michal.environment.terminal;

  oneOrList = T: with types; either T (listOf T);

  # One key combination
  keyModule = types.submodule ({
    config,
    name,
    ...
  }: {
    options = {
      enable = mkOption {
        type = with types; bool;
        default = true;
        description = "Whether the keybind should be used.";
        example = false;
      };
      mods = mkOption {
        type = with types; listOf (enum ["SUPER" "SHIFT" "CONTROL" "ALT"]);
        description = "A list of modifier keys.";
        example = ["SUPER" "SHIFT"];
        default = [];
      };
      key = mkOption {
        type = with types; str;
        description = "The key to bind.";
        example = "Q";
      };
      visible = mkOption {
        type = with types; bool;
        default = true;
        description = "Whether the keybind should be visible in cheat sheet.";
        example = false;
      };
    };
  });

  # One command (dispatcher and params)
  commandModule = types.submodule ({
    config,
    name,
    ...
  }: {
    options = {
      enable = mkOption {
        type = with types; bool;
        default = true;
        description = "Whether the keybind should be used.";
        example = false;
      };
      dispatcher = mkOption {
        type = with types; str;
        description = "The action to perform.";
        example = "workspace";
        default = "exec";
      };
      params = mkOption {
        type = with types; str;
        description = "Additional parameters for the dispatcher.";
        example = "firefox";
        default = "";
      };
      flags = mkOption {
        type = with types; listOf (enum ["locked" "release" "longPress" "repeat" "nonConsuming" "mouse" "transparent" "ignoreMods" "separate" "description" "bypassInhibit"]);
        default = [];
        description = ''          A list of optional flags for the binding. [Docs](https://wiki.hyprland.org/Configuring/Binds/#bind-flags)

          l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
          r -> release, will trigger on release of a key.
          o -> longPress, will trigger on long press of a key.
          e -> repeat, will repeat when held.
          n -> nonConsuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
          m -> mouse, see below.
          t -> transparent, cannot be shadowed by other binds.
          i -> ignoreMods, will ignore modifiers.
          s -> separate, will arbitrarily combine keys between each mod/key, see [Keysym combos](https://wiki.hyprland.org/Configuring/Binds/#keysym-combos) above.
          d -> has description, will allow you to write a description for your bind. (Note: implicitly true, cannot be disabled, do not add it.)
          p -> bypassInhibit, bypasses the app's requests to inhibit keybinds.
        '';
        example = ["repeat"];
      };
    };
  });

  # Typedef for a keybind
  # Guide: https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html
  keybindModule = types.submodule ({
    config,
    name,
    ...
  }: {
    options = {
      description = mkOption {
        type = with types; str;
        default = "";
        description = "An optional description of the binding. Must not include comma.";
        example = "Launch Firefox";
      };
      bind = mkOption {
        type = oneOrList keyModule;
        description = "A keybind (or a list of them) that triggers the command.";
        example = "exec";
        default = "";
      };
      command = mkOption {
        type = oneOrList commandModule;
        description = "A command (or a list of them) to execute on each of the binds.";
        example = "exec";
        default = "";
      };
      visible = mkOption {
        type = with types; bool;
        default = true;
        description = "Whether the keybind should be visible in cheat sheet.";
        example = false;
      };
    };
  });

  # Conversion functions

  # Create the flag suffix. Example: [ "locked" "repeat" ] => "lr"
  constructFlags = flags: let
    table = {
      "locked" = "l";
      "release" = "r";
      "longPress" = "o";
      "repeat" = "e";
      "nonConsuming" = "n";
      "mouse" = "m";
      "transparent" = "t";
      "ignoreMods" = "i";
      "separate" = "s";
      "description" = "d"; # No description
      "bypassInhibit" = "p";
    };
  in
    builtins.concatStringsSep "" (map (f: table.${f}) flags);

  cross = f: arr1: arr2:
    lib.concatLists (map (x: map (y: (f x y)) arr2) arr1);

  # decompress arrays of binds and commands. Now there are surely no arrays
  expandBind = kb:
    cross (cmd: key: {
      inherit (kb) description visible;
      command = cmd;
      bind = key;
    }) (toList kb.command) (toList kb.bind);

  expandedBinds = builtins.concatLists (map expandBind cfg);

  # Get flags of a keybind including those implicitly set
  getFlags = kb: kb.command.flags ++ optionals (kb.description != "") ["description"];

  # Format a bind line. Example: "Super+Shift, up, movewindow, u"
  keybindLine = kb: let
    mods = lib.concatStringsSep " + " kb.bind.mods;
  in
    lib.concatStringsSep ", " [mods kb.bind.key kb.description kb.command.dispatcher kb.command.params];

  bindsByFlag = builtins.groupBy (kb: constructFlags (getFlags kb)) expandedBinds;
  binds = mapAttrs' (flags: kbs: nameValuePair "bind${flags}" (map keybindLine kbs)) bindsByFlag;
in {
  # Define the option
  options.michal.programs.hyprland.keybinds = mkOption {
    type = with types; listOf keybindModule; # todo study why adding attrsOf fails
    default = [];
    description = ''
      A list of key bindings for Hyprland. Each binding is an attribute set
      with attributes such as `mods`, `key`, `dispatcher`, `params`, and `flags`.
    '';
    example = [
      {
        description = "Lock screen";
        bind = [
          {
            mods = ["SUPER"];
            key = "L";
          }
          {
            mods = ["SUPER" "SHIFT"];
            key = "L";
          }
        ];
        command = {
          params = "hyprlock";
          dispatcher = "exec";
          flags = [];
        };
      }
    ];
  };

  config = {
    # Perform some checks
    assertions = [
      {
        assertion = builtins.all (kb: (builtins.match ".*,.*" kb.description) == null) cfg;
        message = "config.michal.programs.hyprland.keybinds[].description must not contain a comma.";
      }
      {
        assertion = builtins.all (kb: allUnique (getFlags kb)) expandedBinds;
        message = "config.michal.programs.hyprland.keybinds[].command.flags have a duplicate.";
      }
    ];

    # Actual keybinds definition
    michal.programs.hyprland.keybinds = let
      ss_flags = {
        monitor = "-m output";
        region = "-m region";
        window = "-m window";
        clipboard = "--clipboard-only"; # default: both storage and clipboard
        freeze = "--freeze";
        stdout = "--raw";
      };
      screen = flagArr: toString (["hyprshot"] ++ flagArr);
      ss_region_stdout = screen (
        with ss_flags; [
          region
          stdout
        ]
      );
      ss_region_clipboard = screen (
        with ss_flags; [
          region
          clipboard
          freeze
        ]
      );
      ss_monitor_file = screen (
        with ss_flags; [
          monitor
        ]
      );

      toggleWindow = name: "ags toggle '${name}'";
      agsRequest = cmd: "ags request '${cmd}'";

      workspaceBinds = num: let
        n = toString num;
      in [
        {
          description = "Toggle Session Menu (shutdown or restart)";
          bind = {
            mods = ["SUPER"];
            key = n;
          };
          command = {
            dispatcher = "workspace";
            params = n;
          };
        }
        {
          description = "Toggle Session Menu (shutdown or restart)";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = n;
          };
          command = {
            dispatcher = "movetoworkspacesilent";
            params = n;
          };
        }
      ];

      allWorkspaceBinds = concatLists (map workspaceBinds (range 1 9));
    in
      allWorkspaceBinds
      ++ [
        {
          description = "Toggle Session Menu (shutdown or restart)";
          bind = {
            mods = ["CONTROL" "ALT"];
            key = "Delete";
          };
          command = {params = toggleWindow "session";};
        }
        {
          description = "Launch terminal";
          bind = {
            mods = ["SUPER"];
            key = "Return";
          };
          command = {params = defaultTerminal;};
        }
        {
          description = "Launch Browser";
          bind = {
            mods = ["SUPER"];
            key = "W";
          };
          command = {params = config.environment.sessionVariables.BROWSER;};
        }
        {
          description = "Launch VSCode";
          bind = {
            mods = ["SUPER"];
            key = "C";
          };
          command = {params = "code --password-store=gnome";};
        }
        {
          description = "Launch file manager";
          bind = {
            mods = ["SUPER"];
            key = "E";
          };
          command = {params = "nautilus --new-window";};
        }
        {
          description = "Launch terminal file manager";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "E";
          };
          command = {params = "${defaultTerminal} -e yazi";};
        }
        {
          description = "Kill active window";
          bind = {
            mods = ["SUPER"];
            key = "Q";
          };
          command = {
            dispatcher = "killactive";
            params = "";
          };
        }
        {
          description = "Select window to kill"; # TODO not working
          bind = {
            mods = ["SHIFT" "SUPER" "ALT"];
            key = "Q";
          };
          command = {params = "hyprctl kill";};
        }
        {
          description = "Launch logout menu"; # TODO not working, also wlogout might not be installed
          bind = {
            mods = ["CONTROL" "SHIFT" "ALT"];
            key = "Delete";
          };
          command = {params = "pkill wlogout || wlogout -p layer-shell";};
        }
        {
          description = "Power off system"; # TODO not working
          bind = {
            mods = ["CONTROL" "SHIFT" "ALT" "SUPER"];
            key = "Delete";
          };
          command = {params = "systemctl poweroff";};
        }
        {
          description = "Open system settings";
          bind = {
            mods = ["SUPER"];
            key = "I";
          };
          command = {params = ''XDG_CURRENT_DESKTOP="gnome" gnome-control-center'';};
        }
        {
          description = "Open volume control";
          bind = {
            mods = ["CONTROL" "SUPER"];
            key = "V";
          };
          command = {params = "pavucontrol";};
        }
        {
          description = "Open system monitor";
          bind = {
            mods = ["CONTROL" "SHIFT"];
            key = "Escape";
          };
          command = {params = "gnome-system-monitor";};
        }
        {
          description = "Toggle floating mode"; # todo float in all workspaces
          bind = {
            mods = ["SUPER" "ALT"];
            key = "Space";
          };
          command = {
            dispatcher = "togglefloating";
            params = "";
          };
        }
        {
          description = "Toggle on-screen keyboard"; # todo not reimplemented
          bind = {
            mods = ["SUPER"];
            key = "K";
          };
          command = {params = toggleWindow "osk";};
        }
        {
          description = "Screenshot region OCR";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "S";
          };
          command = {params = "${ss_region_stdout} | tesseract stdin stdout | wl-copy";};
        }
        {
          description = "Screenshot region to clipboard";
          bind = [
            {
              mods = ["SUPER"];
              key = "S";
            }
            {key = "Print";}
          ];
          command = {params = ss_region_clipboard;};
        }
        {
          description = "Screenshot screen to file";
          bind = {
            mods = ["SUPER" "CONTROL"];
            key = "S";
          };
          command = {params = ss_monitor_file;};
        }
        {
          description = "Screenshot region and edit";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "S";
          };
          command = {params = "${ss_region_stdout} | swappy -f -";};
        }
        {
          description = "Screen recording";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "R";
          };
          command = {params = "record";};
        }
        {
          description = "Fullscreen recording";
          bind = {
            mods = ["CONTROL" "ALT"];
            key = "R";
          };
          command = {params = "record --fullscreen";};
        }
        {
          description = "Fullscreen recording with audio";
          bind = {
            mods = ["SUPER" "SHIFT" "ALT"];
            key = "R";
          };
          command = {params = "record --fullscreen-sound";};
        }
        {
          description = "Color picker";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "C";
          };
          command = {params = "hyprpicker -a";};
        }
        {
          description = "Clipboard history";
          bind = {
            mods = ["SUPER"];
            key = "V";
          };
          command = {params = "pkill fuzzel || cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";};
        }
        {
          description = "Lock screen";
          bind = [
            {
              mods = ["SUPER"];
              key = "L";
            }
            {
              mods = ["SUPER" "SHIFT"];
              key = "L";
            }
          ];
          command = {
            params = "hyprlock";
          };
        }
        {
          description = "Reset AGS"; # TODO
          bind = {
            mods = ["CONTROL" "SUPER"];
            key = "R";
          };
          command = {params = "ags quit; ags run &";};
        }
        {
          description = "Toggle launcher";
          bind = {
            mods = ["SUPER"];
            key = "Tab";
          };
          command = {params = toggleWindow "launcher";};
        }
        {
          description = "Toggle between horizontal and vertical bar";
          bind = {
            mods = ["SUPER"];
            key = "T";
          };
          command = {params = agsRequest "bar-toggle";};
        }
        {
          description = "Toggle cheatsheet";
          bind = {
            mods = ["SUPER"];
            key = "Slash";
          };
          command = {params = toggleWindow "cheatsheet";};
        }
        {
          description = "Set volume to 0%";
          bind = {
            mods = [];
            key = "XF86AudioMute";
          };
          command = {
            params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%";
            flags = ["locked"];
          };
        }
        {
          description = "Set volume to 0%";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "M";
          };
          command = {
            params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%";
            flags = ["locked"];
          };
        }
        {
          description = "Play next track or move to 100% position";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "N";
          };
          command = {
            params = "playerctl next || playerctl position `bc <<< '100 * $(playerctl metadata mpris:length) / 1000000 / 100'`";
            flags = ["locked"];
          };
        }
        {
          description = "Play next track or move to 100% position";
          bind = {
            mods = [];
            key = "XF86AudioNext";
          };
          command = {
            params = "playerctl next || playerctl position `bc <<< '100 * $(playerctl metadata mpris:length) / 1000000 / 100'`";
            flags = ["locked"];
          };
        }
        {
          description = "Play previous track";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "B";
          };
          command = {
            params = "playerctl previous";
            flags = ["locked"];
          };
        }
        {
          description = "Play/pause media";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "P";
          };
          command = {
            params = "playerctl play-pause";
            flags = ["locked"];
          };
        }
        {
          description = "Play/pause media";
          bind = {
            mods = [];
            key = "XF86AudioPlay";
          };
          command = {
            params = "playerctl play-pause";
            flags = ["locked"];
          };
        }
        {
          description = "Suspend system"; # With a delay
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "L";
          };
          command = {
            params = "sleep 0.1 && systemctl suspend";
            flags = ["locked"];
          };
        }
        {
          description = "Show popup via AGS JavaScript"; # todo
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "M";
          };
          command = {
            params = "ags run-js 'indicator.popup(1);'";
            flags = ["locked"];
          };
        }
        {
          description = "Toggle music controls"; # todo
          bind = {
            mods = ["SUPER"];
            key = "M";
          };
          command = {
            params = "ags run-js 'openMusicControls.value = !openMusicControls.value;'";
          };
        }
        {
          description = "Show color scheme"; # todo
          bind = {
            mods = ["SUPER"];
            key = "Comma";
          };
          command = {
            params = "ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'";
          };
        }
        {
          description = "[dev] Test notification";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "F12";
          };
          command = {
            params = "notify-send 'Test notification' 'This is a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!' -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'";
          };
        }
        {
          description = "Urgent notification";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "Equal";
          };
          command = {
            params = "notify-send 'Urgent notification' 'Ah hell no' -u critical -a 'Hyprland keybind'";
          };
        }
        {
          description = "Toggle vertical and horizontal split";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "n";
          };
          command = {
            dispatcher = "togglesplit";
          };
        }
        {
          description = "Move window left";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "Left";
          };
          command = {
            dispatcher = "movewindow";
            params = "l";
          };
        }
        {
          description = "Move window right";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "Right";
          };
          command = {
            dispatcher = "movewindow";
            params = "r";
          };
        }
        {
          description = "Move window up";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "Up";
          };
          command = {
            dispatcher = "movewindow";
            params = "u";
          };
        }
        {
          description = "Move window down";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "Down";
          };
          command = {
            dispatcher = "movewindow";
            params = "d";
          };
        }
        {
          description = "Move focus left";
          bind = [
            {
              mods = ["SUPER"];
              key = "Left";
            }
            {
              mods = ["SUPER"];
              key = "BracketLeft";
            }
          ];
          command = {
            dispatcher = "movefocus";
            params = "l";
          };
        }
        {
          description = "Move focus right";
          bind = [
            {
              mods = ["SUPER"];
              key = "Right";
            }
            {
              mods = ["SUPER"];
              key = "BracketRight";
            }
          ];
          command = {
            dispatcher = "movefocus";
            params = "r";
          };
        }
        {
          description = "Move focus up";
          bind = {
            mods = ["SUPER"];
            key = "Up";
          };
          command = {
            dispatcher = "movefocus";
            params = "u";
          };
        }
        {
          description = "Move focus down";
          bind = {
            mods = ["SUPER"];
            key = "Down";
          };
          command = {
            dispatcher = "movefocus";
            params = "d";
          };
        }
        {
          description = "Switch to next workspace";
          bind = [
            {
              mods = ["CONTROL" "SUPER"];
              key = "Right";
            }
            {
              mods = ["CONTROL" "SUPER"];
              key = "BracketRight";
            }
            {
              mods = ["SUPER"];
              key = "Page_Down";
            }
            {
              mods = ["CONTROL" "SUPER"];
              key = "Page_Down";
            }
          ];
          command = {
            dispatcher = "workspace";
            params = "+1";
          };
        }
        {
          description = "Switch to previous workspace";
          bind = [
            {
              mods = ["CONTROL" "SUPER"];
              key = "Left";
            }
            {
              mods = ["CONTROL" "SUPER"];
              key = "BracketLeft";
            }
            {
              mods = ["SUPER"];
              key = "Page_Up";
            }
            {
              mods = ["CONTROL" "SUPER"];
              key = "Page_Up";
            }
          ];
          command = {
            dispatcher = "workspace";
            params = "-1";
          };
        }
        {
          description = "Switch to workspace 5 above";
          bind = [
            {
              mods = ["CONTROL" "SUPER"];
              key = "Up";
            }
          ];
          command = {
            dispatcher = "workspace";
            params = "-5";
          };
        }
        {
          description = "Switch to workspace 5 below";
          bind = [
            {
              mods = ["CONTROL" "SUPER"];
              key = "Down";
            }
          ];
          command = {
            dispatcher = "workspace";
            params = "+5";
          };
        }
        {
          description = "Move to next workspace";
          bind = [
            {
              mods = ["SUPER" "ALT"];
              key = "Page_Down";
            }
            {
              mods = ["SUPER" "SHIFT"];
              key = "Page_Down";
            }
            {
              mods = ["CONTROL" "SUPER" "SHIFT"];
              key = "Right";
            }
            {
              mods = ["SUPER" "SHIFT"];
              key = "mouse_down";
            }
            {
              mods = ["SUPER" "ALT"];
              key = "mouse_up";
            }
          ];
          command = {
            dispatcher = "movetoworkspace";
            params = "+1";
          };
        }
        {
          description = "Move to previous workspace";
          bind = [
            {
              mods = ["SUPER" "ALT"];
              key = "Page_Up";
            }
            {
              mods = ["SUPER" "SHIFT"];
              key = "Page_Up";
            }
            {
              mods = ["CONTROL" "SUPER" "SHIFT"];
              key = "Left";
            }
            {
              mods = ["SUPER" "SHIFT"];
              key = "mouse_up";
            }
            {
              mods = ["SUPER" "ALT"];
              key = "mouse_down";
            }
          ];
          command = {
            dispatcher = "movetoworkspace";
            params = "-1";
          };
        }
        {
          description = "Fullscreen without topbar";
          bind = {
            mods = ["SUPER"];
            key = "F";
          };
          command = {
            dispatcher = "fullscreen";
            params = "0";
          };
        }
        {
          description = "Fullscreen";
          bind = {
            mods = ["SUPER"];
            key = "D";
          };
          command = {
            dispatcher = "fullscreen";
            params = "1";
          };
        }
        {
          description = "Fullscreen state toggle";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "F";
          };
          command = {
            dispatcher = "fullscreenstate";
            params = "-1 2";
          };
        }
        {
          description = "Move split left";
          bind = [
            {
              mods = ["SUPER"];
              key = "Minus";
            }
            {
              mods = ["SUPER"];
              key = "Semicolon";
            }
          ];
          command = {
            dispatcher = "splitratio";
            params = "-0.1";
            flags = ["repeat"];
          };
        }
        {
          description = "Move split right";
          bind = [
            {
              mods = ["SUPER"];
              key = "Equal";
            }
            {
              mods = ["SUPER"];
              key = "Apostrophe";
            }
          ];
          command = {
            dispatcher = "splitratio";
            params = "0.1";
            flags = ["repeat"];
          };
        }
        {
          description = "Raise volume";
          bind = {key = "XF86AudioRaiseVolume";};
          command = {
            params = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
            flags = ["repeat"];
          };
        }
        {
          description = "Lower volume";
          bind = {key = "XF86AudioLowerVolume";};
          command = {
            params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            flags = ["repeat"];
          };
        }
        {
          description = "Increase brightness";
          bind = {key = "XF86MonBrightnessUp";};
          command = {
            params = "brightnessctl set +10%";
            flags = ["repeat"];
          };
        }
        {
          description = "Decrease brightness";
          bind = {key = "XF86MonBrightnessDown";};
          command = {
            params = "brightnessctl set 10%-";
            flags = ["repeat"];
          };
        }
        {
          description = "Speech to text (hold and speak)";
          bind = {
            mods = ["SUPER"];
            key = "A";
          };
          command = {params = "stt start";};
        }
        {
          description = "Speech to text (hold and speak)";
          bind = {
            mods = ["SUPER"];
            key = "A";
          };
          command = {
            params = "stt stop";
            flags = ["release"];
          };
        }
        {
          description = "Launch application launcher";
          bind = {
            mods = ["SUPER"];
            key = "Space";
          };
          command = {params = "${pkgs.walker}/bin/walker";};
        }
      ];

    home-manager.users.${username} = {
      # Make a json with the keybinds available, for example to ags
      home.file = {
        ".config/keybinds.json".text = builtins.toJSON cfg;
      };

      # Add only binds here, rest of config is elsewhere
      wayland.windowManager.hyprland.settings = binds;
    };
  };
}
