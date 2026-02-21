{ config, lib, ... }:
with lib; {
  config = mkIf config.michal.hyprland.enable {
    michal.programs.hyprland.keybinds = [
      {
        description = "Toggle floating mode"; # todo float in all workspaces
        bind = {
          mods = [ "SUPER" "ALT" ];
          key = "Space";
        };
        command = {
          dispatcher = "togglefloating";
          params = "";
        };
      }
      {
        description = "Toggle vertical and horizontal split";
        bind = {
          mods = [ "SUPER" "SHIFT" ];
          key = "n";
        };
        command = { dispatcher = "togglesplit"; };
      }
      {
        description = "Move window left";
        bind = {
          mods = [ "SUPER" "SHIFT" ];
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
          mods = [ "SUPER" "SHIFT" ];
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
          mods = [ "SUPER" "SHIFT" ];
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
          mods = [ "SUPER" "SHIFT" ];
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
            mods = [ "SUPER" ];
            key = "Left";
          }
          {
            mods = [ "SUPER" ];
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
            mods = [ "SUPER" ];
            key = "Right";
          }
          {
            mods = [ "SUPER" ];
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
          mods = [ "SUPER" ];
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
          mods = [ "SUPER" ];
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
            mods = [ "CONTROL" "SUPER" ];
            key = "Right";
          }
          {
            mods = [ "CONTROL" "SUPER" ];
            key = "BracketRight";
          }
          {
            mods = [ "SUPER" ];
            key = "Page_Down";
          }
          {
            mods = [ "CONTROL" "SUPER" ];
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
            mods = [ "CONTROL" "SUPER" ];
            key = "Left";
          }
          {
            mods = [ "CONTROL" "SUPER" ];
            key = "BracketLeft";
          }
          {
            mods = [ "SUPER" ];
            key = "Page_Up";
          }
          {
            mods = [ "CONTROL" "SUPER" ];
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
        bind = [{
          mods = [ "CONTROL" "SUPER" ];
          key = "Up";
        }];
        command = {
          dispatcher = "workspace";
          params = "-5";
        };
      }
      {
        description = "Switch to workspace 5 below";
        bind = [{
          mods = [ "CONTROL" "SUPER" ];
          key = "Down";
        }];
        command = {
          dispatcher = "workspace";
          params = "+5";
        };
      }
      {
        description = "Move to next workspace";
        bind = [
          {
            mods = [ "SUPER" "ALT" ];
            key = "Page_Down";
          }
          {
            mods = [ "SUPER" "SHIFT" ];
            key = "Page_Down";
          }
          {
            mods = [ "CONTROL" "SUPER" "SHIFT" ];
            key = "Right";
          }
          {
            mods = [ "SUPER" "SHIFT" ];
            key = "mouse_down";
          }
          {
            mods = [ "SUPER" "ALT" ];
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
            mods = [ "SUPER" "ALT" ];
            key = "Page_Up";
          }
          {
            mods = [ "SUPER" "SHIFT" ];
            key = "Page_Up";
          }
          {
            mods = [ "CONTROL" "SUPER" "SHIFT" ];
            key = "Left";
          }
          {
            mods = [ "SUPER" "SHIFT" ];
            key = "mouse_up";
          }
          {
            mods = [ "SUPER" "ALT" ];
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
          mods = [ "SUPER" ];
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
          mods = [ "SUPER" ];
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
          mods = [ "SUPER" "ALT" ];
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
            mods = [ "SUPER" ];
            key = "Minus";
          }
          {
            mods = [ "SUPER" ];
            key = "Semicolon";
          }
        ];
        command = {
          dispatcher = "splitratio";
          params = "-0.1";
          flags = [ "repeat" ];
        };
      }
      {
        description = "Move split right";
        bind = [
          {
            mods = [ "SUPER" ];
            key = "Equal";
          }
          {
            mods = [ "SUPER" ];
            key = "Apostrophe";
          }
        ];
        command = {
          dispatcher = "splitratio";
          params = "0.1";
          flags = [ "repeat" ];
        };
      }
    ];
  };
}
