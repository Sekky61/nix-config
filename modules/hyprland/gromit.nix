{
  pkgs,
  username,
  ...
}: {
  # Gromit-mpx is program for drawing to screen
  #
  # - TODO the drawing area is probably cropped due to monitor scaling

  environment.systemPackages = with pkgs; [
    gromit-mpx # Draw on screen
  ];

  michal.programs.hyprland.keybinds = [
    {
      description = "Toggle drawing to screen"; # TODO toggle off does not work (kill it with super+q)
      bind = {key = "F7";};
      command = {
        dispatcher = "togglespecialworkspace";
        params = "gromit";
      };
    }
    {
      description = "Clear drawing";
      bind = {
        mods = ["SHIFT"];
        key = "F7";
      };
      command = {params = "gromit-mpx --clear";};
    }
    {
      description = "Drawing: Undo";
      bind = {key = "F6";};
      command = {params = "gromit-mpx --undo";};
    }
    {
      description = "Drawing: Redo";
      bind = {
        mods = ["SHIFT"];
        key = "F6";
      };
      command = {params = "gromit-mpx --redo";};
    }
  ];

  home-manager.users.${username} = _: {
    wayland.windowManager.hyprland = {
      settings = {
        windowrule = [
          "noblur, ^(Gromit-mpx)$"
          "opacity 1 override, 1 override, ^(Gromit-mpx)$"
          "noshadow, ^(Gromit-mpx)$"
          "size 100% 100%, ^(Gromit-mpx)$"
        ];
        workspace = [
          "special:gromit, gapsin:0, gapsout:0, on-created-empty: gromit-mpx -a"
        ];
      };
    };
  };
}
