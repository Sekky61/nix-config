{
  username,
  config,
  lib,
  pkgs,
  ...
}: {
  # Gromit-mpx is program for drawing to screen
  #
  # - TODO the drawing area is probably cropped due to monitor scaling

  config = lib.mkIf config.michal.hyprland.enable {
    environment.systemPackages = with pkgs; [
      gromit-mpx # Draw on screen
    ];

    home-manager.users.${username} = {
      services.gromit-mpx = {
        enable = true;
        hotKey = null;
        tools = [
          {
            device = "default";
            type = "pen";
            size = 3;
          }
          {
            device = "default";
            type = "pen";
            color = "blue";
            size = 3;
            modifiers = ["SHIFT"];
          }
          {
            device = "default";
            type = "pen";
            color = "black";
            size = 3;
            modifiers = ["CONTROL"];
          }
          {
            device = "default";
            type = "pen";
            color = "white";
            size = 3;
            modifiers = ["2"];
          }
          {
            device = "default";
            type = "eraser";
            size = 30;
            modifiers = ["3"];
          }
        ];
      };
    };

    michal.programs.hyprland.keybinds = [
      {
        description = "Toggle drawing to screen";
        bind = {key = "F7";};
        command = {
          lua = ''hl.dsp.workspace.toggle_special("gromit")'';
        };
      }
      {
        description = "Clear drawing";
        bind = {
          mods = ["SHIFT"];
          key = "F7";
        };
        command = {exec = "gromit-mpx --clear";};
      }
      {
        description = "Drawing: Undo";
        bind = {key = "F6";};
        command = {exec = "gromit-mpx --undo";};
      }
      {
        description = "Drawing: Redo";
        bind = {
          mods = ["SHIFT"];
          key = "F6";
        };
        command = {exec = "gromit-mpx --redo";};
      }
    ];
  };
}
