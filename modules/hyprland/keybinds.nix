{
  inputs,
  pkgs,
  lib,
  username,
  config,
  ...
}:
with lib;
let
  # Define all binds for Hyprland
  #
  # - SUPER is the Win key

  cfg = config.michal.programs.hyprland.keybinds;

  # Typedef for a keybind
  # Guide: https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html
  keybindModule = types.submodule ({
    config,
    name,
    ...
  }: {
      options = {
        mods = mkOption {
          type = with types; listOf (enum [ "SUPER" "SHIFT" "CONTROL" "ALT" ]);
          description = "A list of modifier keys.";
          example = [ "SUPER" "SHIFT" ];
          default = [];
        };
        key = mkOption {
          type = with types; str;
          description = "The key to bind.";
          example = "Q";
          default = "";
        };
        dispatcher = mkOption {
          type = with types; str;
          description = "The action to perform.";
          example = "exec";
          default = "";
        };
        params = mkOption {
          type = with types; either str (listOf str);
          description = "Additional parameters for the dispatcher. Can be an array of params, in which case multiple binds differing only in params will be created.";
          example = "firefox";
          default = "";
        };
        description = mkOption {
          type = with types; str;
          default = "";
          description = "An optional description of the binding. Must not include comma.";
          example = "Launch Firefox";
        };
        flags = mkOption {
          type = with types; listOf (enum [ "locked" "release" "longPress" "repeat" "nonConsuming" "mouse" "transparent" "ignoreMods" "separate" "description" "bypassInhibit" ]);
          default = [ ];
          description = ''A list of optional flags for the binding. [Docs](https://wiki.hyprland.org/Configuring/Binds/#bind-flags)

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
          example = [ "repeat" ];
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
  constructFlags = flags:
    let
      table = {
        "locked" = "l";
        "release" = "r";
        "longPress" = "o";
        "repeat" = "r";
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

  # Get flags of a keybind including those implicitly set
  getFlags = kb: kb.flags ++ optionals (kb.description != "") ["description"];

  # Format a bind line. Example: "Super+Shift, up, movewindow, u"
  keybindLines = kb:
    let
      mods = lib.concatStringsSep " + " kb.mods;
      paramArr = lists.toList kb.params;
      createLine = par: lib.concatStringsSep ", " [mods kb.key kb.description kb.dispatcher par];
    in
      map createLine paramArr;
      

  # [ { mods, flags, ... } ] => [ { bind[f] = ["line" "line2"] } ]
  bb = map (kb: { "bind${constructFlags (getFlags kb)}" = keybindLines kb;}) cfg;

  # { "bindxx" = [ ["line1"] ["line2"] ] }
  bindsNested = builtins.zipAttrsWith (name: valueLine: valueLine) bb;
  # { "bindxx" = [ ["line1"] ["line2"] ] }
  binds = mapAttrs (name: value: flatten value) bindsNested;
in
{
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
        mods = [ "SUPER" "SHIFT" ];
        key = "Q";
        dispatcher = "exec";
        params = "firefox";
        description = "Launch Firefox";
        flags = [ "repeat" ];
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
        assertion = builtins.all (kb: allUnique (getFlags kb)) cfg;
        message = "config.michal.programs.hyprland.keybinds[].flags have a duplicate.";
      }
    ];

    # Actual keybinds definition
    michal.programs.hyprland.keybinds = 
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

        toggleWindow = name: "ags toggle '${name}'";

      in [
      {
        description = "Toggle Session Menu (shutdown or restart)";
        params = toggleWindow "session";
        mods = [ "CONTROL" "ALT" ];
        key = "Delete";
        dispatcher = "exec";
        flags = [ "repeat" ];
      }
      {
        description = "Launch application launcher (anyrun)";
        params = toggleWindow "launcher";
        mods = [ "SUPER" ];
        key = "Space";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Launch terminal";
        params = "alacritty";
        mods = [ "SUPER" ];
        key = "Return";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Launch Chrome";
        params = "google-chrome-stable";
        mods = [ "SUPER" ];
        key = "W";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Launch VSCode";
        params = "code --password-store=gnome";
        mods = [ "SUPER" ];
        key = "C";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Launch file manager";
        params = "nautilus --new-window";
        mods = [ "SUPER" ];
        key = "E";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Launch terminal file manager";
        params = "alacritty -e yazi";
        mods = [ "SUPER" "ALT" ];
        key = "E";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Kill active window";
        params = "";
        mods = [ "SUPER" ];
        key = "Q";
        dispatcher = "killactive";
        flags = [ ];
      }
      {
        description = "Select window to kill"; # TODO not working
        params = "hyprctl kill";
        mods = [ "SHIFT" "SUPER" "ALT" ];
        key = "Q";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Launch logout menu"; # TODO not working, also wlogout might not be installed
        params = "pkill wlogout || wlogout -p layer-shell";
        mods = [ "CONTROL" "SHIFT" "ALT" ];
        key = "Delete";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Power off system"; # TODO not working
        params = "systemctl poweroff";
        mods = [ "CONTROL" "SHIFT" "ALT" "SUPER" ];
        key = "Delete";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Open system settings";
        params = ''XDG_CURRENT_DESKTOP="gnome" gnome-control-center'';
        mods = [ "SUPER" ];
        key = "I";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Open volume control";
        params = "pavucontrol";
        mods = [ "CONTROL" "SUPER" ];
        key = "V";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Open system monitor";
        params = "gnome-system-monitor";
        mods = [ "CONTROL" "SHIFT" ];
        key = "Escape";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Open emoji picker";
        params = "bemoji";
        mods = [ "SUPER" ];
        key = "Period";
        dispatcher = "exec";
        flags = [ ];
      }
      {
        description = "Toggle floating mode";
        params = "";
        mods = [ "SUPER" "ALT" ];
        key = "Space";
        dispatcher = "togglefloating";
        flags = [ ];
      }
      {
        description = "Toggle on-screen keyboard"; # todo not reimplemented
        params = toggleWindow "osk";
        mods = [ "SUPER" ];
        key = "K";
        dispatcher = "exec";
        flags = [ ];
      }
       {
         description = "Screenshot region OCR";
         params = ss_region_clipboard;
         mods = [ ];
         key = "Print";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Screenshot region OCR"; 
         params = "${ss_region_stdout} | tesseract stdin stdout | wl-copy";
         mods = [ "SUPER" "SHIFT" ];
         key = "S";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Screenshot region to clipboard";
         params = ss_region_clipboard;
         mods = [ "SUPER" ];
         key = "S"; 
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Screenshot region and edit";
         params = "${ss_region_stdout} | swappy -f -";
         mods = [ "SUPER" "ALT" ];
         key = "S";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Screen recording";
         params = "record";
         mods = [ "SUPER" "ALT" ];
         key = "R";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Fullscreen recording";
         params = "record --fullscreen";
         mods = [ "CONTROL" "ALT" ];
         key = "R";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Fullscreen recording with audio";
         params = "record --fullscreen-sound";
         mods = [ "SUPER" "SHIFT" "ALT" ];
         key = "R";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Color picker";
         params = "hyprpicker -a";
         mods = [ "SUPER" "SHIFT" ];
         key = "C";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Clipboard history";
         params = "pkill fuzzel || cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";
         mods = [ "SUPER" ];
         key = "V";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Lock screen";
         params = "hyprlock";
         mods = [ "SUPER" ];
         key = "L";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Lock screen";
         params = "hyprlock";
         mods = [ "SUPER" "SHIFT" ];
         key = "L";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Launch application launcher";
         params = "pkill anyrun || anyrun";
         mods = [ "CONTROL" "SUPER" ];
         key = "Slash";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Switch wallpaper"; # todo needs testing
         params = "~/.config/ags/scripts/color_generation/switchwall.sh";
         mods = [ "CONTROL" "SUPER" ];
         key = "T";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Reset AGS"; # TODO
         params = "ags quit; ags run &";
         mods = [ "CONTROL" "SUPER" ];
         key = "R";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Toggle launcher";
         params = toggleWindow "launcher";
         mods = [ "SUPER" ];
         key = "Tab";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Toggle cheatsheet"; # todo
         params = toggleWindow "cheatsheet";
         mods = [ "SUPER" ];
         key = "Slash";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Toggle side menu left"; # todo
         params = toggleWindow "sideleft";
         mods = [ "SUPER" ];
         key = "B";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Toggle side menu left"; # todo
         params = toggleWindow "sideleft";
         mods = [ "SUPER" ];
         key = "A";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Toggle side menu left"; # todo
         params = toggleWindow "sideleft";
         mods = [ "SUPER" ];
         key = "O";
         dispatcher = "exec";
         flags = [ ];
       }
       {
         description = "Toggle side menu right"; # todo
         params = toggleWindow "sideright";
         mods = [ "SUPER" ];
         key = "N";
         dispatcher = "exec";
         flags = [ ];
       }
      {
        description = "Set volume to 0%";
        params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%";
        mods = [ ];
        key = "XF86AudioMute";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Set volume to 0%";
        params = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%";
        mods = [ "SUPER" "SHIFT" ];
        key = "M";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Play next track or move to 100% position";
        params = "playerctl next || playerctl position `bc <<< '100 * $(playerctl metadata mpris:length) / 1000000 / 100'`";
        mods = [ "SUPER" "SHIFT" ];
        key = "N";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Play next track or move to 100% position";
        params = "playerctl next || playerctl position `bc <<< '100 * $(playerctl metadata mpris:length) / 1000000 / 100'`";
        mods = [ ];
        key = "XF86AudioNext";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Play previous track";
        params = "playerctl previous";
        mods = [ "SUPER" "SHIFT" ];
        key = "B";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Play/pause media";
        params = "playerctl play-pause";
        mods = [ "SUPER" "SHIFT" ];
        key = "P";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Play/pause media";
        params = "playerctl play-pause";
        mods = [ ];
        key = "XF86AudioPlay";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Suspend system"; # With a delay
        params = "sleep 0.1 && systemctl suspend";
        mods = [ "SUPER" "SHIFT" ];
        key = "L";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Show popup via AGS JavaScript"; # todo
        params = "ags run-js 'indicator.popup(1);'";
        mods = [ ];
        key = "XF86AudioMute";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
      {
        description = "Show popup via AGS JavaScript"; # todo
        params = "ags run-js 'indicator.popup(1);'";
        mods = [ "SUPER" "SHIFT" ];
        key = "M";
        dispatcher = "exec";
        flags = [ "locked" ];
      }
    ];

    home-manager.users.${username} = _: {

      # Make a json with the keybinds available, for example to ags
      home.file = {
        ".config/keybinds.json".text = builtins.toJSON cfg;
      };

      # Add only binds here, rest of config is elsewhere
      wayland.windowManager.hyprland.settings = binds;
    };
  };
}
