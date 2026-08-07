{
  username,
  config,
  lib,
  pkgs,
  ...
}: let
  gromitControl = pkgs.writeShellApplication {
    name = "gromit-control";
    runtimeInputs = with pkgs; [
      coreutils
      gromit-mpx
      systemd
    ];
    text = ''
      if systemctl --user is-active --quiet gromit-mpx.service; then
        if [[ "''${1:-}" == "--toggle" ]]; then
          exec gromit-mpx --quit
        fi

        exec gromit-mpx "$@"
      fi

      if [[ "''${1:-}" != "--toggle" ]]; then
        exit 0
      fi

      systemctl --user start gromit-mpx.service
      sleep 0.1
      exec gromit-mpx --toggle
    '';
  };
in {
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
        undoKey = null;
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

      # Start Gromit only after the first toggle. The standard module starts it
      # for each graphical session and can take focus during Home Manager switches.
      systemd.user.services.gromit-mpx.Install.WantedBy = lib.mkForce [];
    };

    michal.programs.hyprland.keybinds = let
      control = action: "${gromitControl}/bin/gromit-control ${action}";
    in [
      {
        description = "Toggle screen drawing";
        bind = {key = "F7";};
        command = {exec = control "--toggle";};
      }
      {
        description = "Clear screen drawing";
        bind = {
          mods = ["SHIFT"];
          key = "F7";
        };
        command = {exec = control "--clear";};
      }
      {
        description = "Hide screen drawing";
        bind = {
          mods = ["CONTROL"];
          key = "F7";
        };
        command = {exec = control "--visibility";};
      }
      {
        description = "Undo screen drawing";
        bind = {key = "F6";};
        command = {exec = control "--undo";};
      }
      {
        description = "Redo screen drawing";
        bind = {
          mods = ["SHIFT"];
          key = "F6";
        };
        command = {exec = control "--redo";};
      }
    ];
  };
}
