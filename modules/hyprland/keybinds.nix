{
  lib,
  username,
  config,
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

  # One command. Use exec for shell commands and lua for Hyprland Lua actions.
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
      exec = mkOption {
        type = with types; str;
        description = "Shell command to execute.";
        example = "firefox";
        default = "";
      };
      lua = mkOption {
        type = with types; str;
        description = "Lua expression that returns a Hyprland bind action.";
        example = ''hl.dsp.focus({ workspace = "1" })'';
        default = "";
      };
      flags = mkOption {
        type = with types;
          listOf (enum [
            "locked"
            "release"
            "longPress"
            "repeat"
            "nonConsuming"
            "mouse"
            "transparent"
            "ignoreMods"
            "separate"
            "description"
            "bypassInhibit"
          ]);
        default = [];
        description = ''
          A list of optional flags for the binding. [Docs](https://wiki.hyprland.org/Configuring/Binds/#bind-flags)

          l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
          r -> release, will trigger on release of a key.
          o -> longPress, will trigger on long press of a key.
          e -> repeat, will repeat when held.
          n -> nonConsuming, key/mouse events will be passed to the active window in addition to triggering the action.
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

  cross = f: arr1: arr2: lib.concatLists (map (x: map (y: (f x y)) arr2) arr1);

  # decompress arrays of binds and commands. Now there are surely no arrays
  expandBind = kb:
    cross (cmd: key: {
      inherit (kb) description visible;
      command = cmd;
      bind = key;
    }) (toList kb.command) (toList kb.bind);

  expandedBinds = builtins.concatLists (map expandBind cfg);

  # Get flags of a keybind including those implicitly set
  getFlags = kb:
    kb.command.flags ++ optionals (kb.description != "") ["description"];

  # todo can be removed
  luaOptionName = flag:
    {
      "locked" = "locked";
      "release" = "release";
      "longPress" = "long_press";
      "repeat" = "repeating";
      "nonConsuming" = "non_consuming";
      "mouse" = "mouse";
      "transparent" = "transparent";
      "ignoreMods" = "ignore_mods";
      "separate" = "separate";
      "bypassInhibit" = "dont_inhibit";
    }.${
      flag
    };

  luaModName = mod:
    {
      "CONTROL" = "CTRL";
    }
    .${
      mod
    }
    or mod;

  luaKeyName = key:
    {
      "Left" = "left";
      "Right" = "right";
      "Up" = "up";
      "Down" = "down";
      "Page_Up" = "page_up";
      "Page_Down" = "page_down";
      "Space" = "space";
      "Return" = "return";
    }
    .${
      key
    }
    or key;

  luaBindKeys = kb:
    concatStringsSep " + " ((map luaModName kb.bind.mods) ++ [(luaKeyName kb.bind.key)]);

  luaBindOptions = kb: let
    flags = getFlags kb;
    optionFlags = filter (flag: flag != "description") flags;
    options =
      map (flag: "${luaOptionName flag} = true") optionFlags
      ++ optionals (kb.description != "") ["description = ${lib.generators.toLua {} kb.description}"];
  in
    if options == []
    then "nil"
    else "{ ${concatStringsSep ", " options} }";

  luaAction = kb: let
    toLua = lib.generators.toLua {};
    command = kb.command;
  in
    if command.lua != ""
    then command.lua
    else "hl.dsp.exec_cmd(${toLua command.exec})";

  luaBindLine = kb: ''
    {
      keys = ${lib.generators.toLua {} (luaBindKeys kb)},
      action = ${luaAction kb},
      options = ${luaBindOptions kb},
    },
  '';
in {
  # Define the option
  options.michal.programs.hyprland.keybinds = mkOption {
    type = with types;
      listOf keybindModule; # todo study why adding attrsOf fails
    default = [];
    description = ''
      A list of key bindings for Hyprland. Each binding is an attribute set
      with attributes such as `mods`, `key`, `exec`, `lua`, and `flags`.
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
          exec = "hyprlock";
          flags = [];
        };
      }
    ];
  };

  config = mkIf config.michal.hyprland.enable {
    # Perform some checks
    assertions = [
      {
        assertion =
          builtins.all (kb: (builtins.match ".*,.*" kb.description) == null)
          cfg;
        message = "config.michal.programs.hyprland.keybinds[].description must not contain a comma.";
      }
      {
        assertion = builtins.all (kb: allUnique (getFlags kb)) expandedBinds;
        message = "config.michal.programs.hyprland.keybinds[].command.flags have a duplicate.";
      }
      {
        assertion = builtins.all (kb: (kb.command.exec != "") != (kb.command.lua != "")) expandedBinds;
        message = "config.michal.programs.hyprland.keybinds[].command must set exactly one of exec or lua.";
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
      ss_region_stdout = screen (with ss_flags; [region stdout]);
      ss_region_clipboard = screen (with ss_flags; [region clipboard freeze]);
      ss_monitor_file = screen (with ss_flags; [monitor]);

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
            lua = ''hl.dsp.focus({ workspace = "${n}" })'';
          };
        }
        {
          description = "Toggle Session Menu (shutdown or restart)";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = n;
          };
          command = {
            lua = ''hl.dsp.window.move({ workspace = "${n}" })'';
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
          command = {exec = toggleWindow "session";};
        }
        {
          description = "Launch terminal";
          bind = {
            mods = ["SUPER"];
            key = "Return";
          };
          command = {exec = defaultTerminal;};
        }
        {
          description = "Launch Browser";
          bind = {
            mods = ["SUPER"];
            key = "W";
          };
          command = {exec = config.environment.sessionVariables.BROWSER;};
        }
        {
          description = "Launch VSCode";
          bind = {
            mods = ["SUPER"];
            key = "C";
          };
          command = {exec = "code --password-store=gnome";};
        }
        {
          description = "Launch file manager";
          bind = {
            mods = ["SUPER"];
            key = "E";
          };
          command = {exec = "nautilus --new-window";};
        }
        {
          description = "Launch terminal file manager";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "E";
          };
          command = {exec = "${defaultTerminal} -e yazi";};
        }
        {
          description = "Kill active window";
          bind = {
            mods = ["SUPER"];
            key = "Q";
          };
          command = {
            lua = "hl.dsp.window.close()";
          };
        }
        {
          description = "Select window to kill"; # TODO not working
          bind = {
            mods = ["SHIFT" "SUPER" "ALT"];
            key = "Q";
          };
          command = {exec = "hyprctl kill";};
        }
        {
          description = "Launch logout menu"; # TODO not working, also wlogout might not be installed
          bind = {
            mods = ["CONTROL" "SHIFT" "ALT"];
            key = "Delete";
          };
          command = {exec = "pkill wlogout || wlogout -p layer-shell";};
        }
        {
          description = "Power off system"; # TODO not working
          bind = {
            mods = ["CONTROL" "SHIFT" "ALT" "SUPER"];
            key = "Delete";
          };
          command = {exec = "systemctl poweroff";};
        }
        {
          description = "Set power profile: performance";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "1";
          };
          command = {
            exec = "powerprofilesctl set performance && notify-send 'Power profile' 'Performance' -a 'Power Profiles'";
          };
        }
        {
          description = "Set power profile: balanced";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "2";
          };
          command = {
            exec = "powerprofilesctl set balanced && notify-send 'Power profile' 'Balanced' -a 'Power Profiles'";
          };
        }
        {
          description = "Set power profile: power saver";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "3";
          };
          command = {
            exec = "powerprofilesctl set power-saver && notify-send 'Power profile' 'Power Saver' -a 'Power Profiles'";
          };
        }
        {
          description = "Open system settings";
          bind = {
            mods = ["SUPER"];
            key = "I";
          };
          command = {
            exec = ''XDG_CURRENT_DESKTOP="gnome" gnome-control-center'';
          };
        }
        {
          description = "Open system monitor";
          bind = {
            mods = ["CONTROL" "SHIFT"];
            key = "Escape";
          };
          command = {exec = "gnome-system-monitor";};
        }
        {
          description = "Toggle on-screen keyboard"; # todo not reimplemented
          bind = {
            mods = ["SUPER"];
            key = "K";
          };
          command = {exec = toggleWindow "osk";};
        }
        {
          description = "Screenshot region OCR";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "S";
          };
          command = {
            exec = "${ss_region_stdout} | tesseract stdin stdout | wl-copy";
          };
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
          command = {exec = ss_region_clipboard;};
        }
        {
          description = "Screenshot screen to file";
          bind = {
            mods = ["SUPER" "CONTROL"];
            key = "S";
          };
          command = {exec = ss_monitor_file;};
        }
        {
          description = "Screenshot region and edit";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "S";
          };
          command = {exec = "${ss_region_stdout} | swappy -f -";};
        }
        {
          description = "Screen recording";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "R";
          };
          command = {exec = "record";};
        }
        {
          description = "Fullscreen recording";
          bind = {
            mods = ["CONTROL" "ALT"];
            key = "R";
          };
          command = {exec = "record --fullscreen";};
        }
        {
          description = "Fullscreen recording with audio";
          bind = {
            mods = ["SUPER" "SHIFT" "ALT"];
            key = "R";
          };
          command = {exec = "record --fullscreen-sound";};
        }
        {
          description = "Color picker";
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "C";
          };
          command = {exec = "hyprpicker -a";};
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
          command = {exec = "hyprlock";};
        }
        {
          description = "Reset AGS"; # TODO
          bind = {
            mods = ["CONTROL" "SUPER"];
            key = "R";
          };
          command = {exec = "ags quit; ags run &";};
        }
        {
          description = "Toggle launcher";
          bind = {
            mods = ["SUPER"];
            key = "Tab";
          };
          command = {exec = toggleWindow "launcher";};
        }
        {
          description = "Toggle between horizontal and vertical bar";
          bind = {
            mods = ["SUPER"];
            key = "T";
          };
          command = {exec = agsRequest "bar-toggle";};
        }
        {
          description = "Toggle cheatsheet";
          bind = {
            mods = ["SUPER"];
            key = "Slash";
          };
          command = {exec = toggleWindow "cheatsheet";};
        }
        {
          description = "Suspend system"; # With a delay
          bind = {
            mods = ["SUPER" "SHIFT"];
            key = "L";
          };
          command = {
            exec = "sleep 0.1 && systemctl suspend";
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
            exec = "ags run-js 'indicator.popup(1);'";
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
            exec = "ags run-js 'openMusicControls.value = !openMusicControls.value;'";
          };
        }
        {
          description = "Show color scheme"; # todo
          bind = {
            mods = ["SUPER"];
            key = "Comma";
          };
          command = {
            exec = "ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'";
          };
        }
        {
          description = "[dev] Test notification";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "F12";
          };
          command = {
            exec = "notify-send 'Test notification' 'This is a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!' -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'";
          };
        }
        {
          description = "Urgent notification";
          bind = {
            mods = ["SUPER" "ALT"];
            key = "Equal";
          };
          command = {
            exec = "notify-send 'Urgent notification' 'Ah hell no' -u critical -a 'Hyprland keybind'";
          };
        }
        {
          description = "Increase brightness";
          bind = {key = "XF86MonBrightnessUp";};
          command = {
            exec = "brightnessctl set +10%";
            flags = ["repeat"];
          };
        }
        {
          description = "Decrease brightness";
          bind = {key = "XF86MonBrightnessDown";};
          command = {
            exec = "brightnessctl set 10%-";
            flags = ["repeat"];
          };
        }
        {
          description = "Speech to text (hold and speak)";
          bind = {
            mods = ["SUPER"];
            key = "A";
          };
          command = {exec = "stt start";};
        }
        {
          description = "Speech to text (hold and speak)";
          bind = {
            mods = ["SUPER"];
            key = "A";
          };
          command = {
            exec = "stt stop";
            flags = ["release"];
          };
        }
        {
          description = "Handy push to talk";
          bind = {
            mods = ["SUPER"];
            key = "Z";
          };
          # First cancel the recording, then start recording again.
          command = {exec = "handy --cancel; handy --toggle-transcription";};
        }
        {
          description = "Handy push to talk";
          bind = {
            mods = ["SUPER"];
            key = "Z";
          };
          command = {
            exec = "handy --toggle-transcription";
            flags = ["release"];
          };
        }
      ];

    home-manager.users.${username} = {
      # Make a json with the keybinds available, for example to ags
      home.file = {".config/keybinds.json".text = builtins.toJSON cfg;};
    };

    michal.hyprland.generatedFiles."generated/keybinds.lua" = ''
      -- Generated from config.michal.programs.hyprland.keybinds.
      require("hypr.keybinds").bind_all({
      ${concatStringsSep "\n" (map luaBindLine expandedBinds)}
      })
    '';
  };
}
