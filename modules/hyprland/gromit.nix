{
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

    michal.programs.hyprland.keybinds = [
      {
        description = "Toggle drawing to screen"; # TODO toggle off does not work (kill it with super+q)
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
