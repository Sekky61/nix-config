{
  config,
  lib,
  ...
}:
with lib; {
  config = mkIf config.michal.hyprland.enable {
    michal.programs.hyprland.keybinds = [
      {
        description = "Toggle floating mode"; # todo float in all workspaces
        bind = {
          mods = ["SUPER" "ALT"];
          key = "Space";
        };
        command = {
          lua = ''hl.dsp.window.float({ action = "toggle" })'';
        };
      }
      {
        description = "Toggle vertical and horizontal split";
        bind = {
          mods = ["SUPER" "SHIFT"];
          key = "n";
        };
        command = {
          lua = ''hl.dsp.layout("togglesplit")'';
        };
      }
      {
        description = "Move window left";
        bind = {
          mods = ["SUPER" "SHIFT"];
          key = "Left";
        };
        command = {
          lua = ''hl.dsp.window.move({ direction = "left" })'';
        };
      }
      {
        description = "Move window right";
        bind = {
          mods = ["SUPER" "SHIFT"];
          key = "Right";
        };
        command = {
          lua = ''hl.dsp.window.move({ direction = "right" })'';
        };
      }
      {
        description = "Move window up";
        bind = {
          mods = ["SUPER" "SHIFT"];
          key = "Up";
        };
        command = {
          lua = ''hl.dsp.window.move({ direction = "up" })'';
        };
      }
      {
        description = "Move window down";
        bind = {
          mods = ["SUPER" "SHIFT"];
          key = "Down";
        };
        command = {
          lua = ''hl.dsp.window.move({ direction = "down" })'';
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
          lua = ''hl.dsp.focus({ direction = "left" })'';
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
          lua = ''hl.dsp.focus({ direction = "right" })'';
        };
      }
      {
        description = "Move focus up";
        bind = {
          mods = ["SUPER"];
          key = "Up";
        };
        command = {
          lua = ''hl.dsp.focus({ direction = "up" })'';
        };
      }
      {
        description = "Move focus down";
        bind = {
          mods = ["SUPER"];
          key = "Down";
        };
        command = {
          lua = ''hl.dsp.focus({ direction = "down" })'';
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
          lua = ''hl.dsp.focus({ workspace = "+1" })'';
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
          lua = ''hl.dsp.focus({ workspace = "-1" })'';
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
          lua = ''hl.dsp.focus({ workspace = "-5" })'';
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
          lua = ''hl.dsp.focus({ workspace = "+5" })'';
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
          lua = ''hl.dsp.window.move({ workspace = "+1" })'';
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
          lua = ''hl.dsp.window.move({ workspace = "-1" })'';
        };
      }
      {
        description = "Fullscreen without topbar";
        bind = {
          mods = ["SUPER"];
          key = "F";
        };
        command = {
          lua = ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'';
        };
      }
      {
        description = "Fullscreen";
        bind = {
          mods = ["SUPER"];
          key = "D";
        };
        command = {
          lua = ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })'';
        };
      }
      {
        description = "Fullscreen state toggle";
        bind = {
          mods = ["SUPER" "ALT"];
          key = "F";
        };
        command = {
          lua = ''hl.dsp.window.fullscreen_state({ internal = -1, client = 2, action = "toggle" })'';
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
          lua = ''hl.dsp.layout("mfact -0.1")'';
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
          lua = ''hl.dsp.layout("mfact +0.1")'';
          flags = ["repeat"];
        };
      }
    ];
  };
}
