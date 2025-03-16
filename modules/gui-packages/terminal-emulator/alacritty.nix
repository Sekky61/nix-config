{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.alacritty;
  alacritty = "alacritty";
in {
  options.michal.programs.alacritty = {
    enable = mkEnableOption alacritty;
    default = mkEnableOption "alacritty to be the default terminal emulator";
  };
  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.alacritty = {
        enable = true;
        settings = {
          keyboard.bindings = [
            # Clone window with the same CWD
            {
              key = "N";
              mods = "Control|Shift";
              action = "CreateNewWindow";
            }
          ];
          font = {
            # Font names can be a mess, but this one is tested, working
            normal = {family = "MonaspiceNe Nerd Font Mono";};
          };
          window.opacity = 0.94;
        };
      };
    };

    michal.environment = mkIf cfg.default {
      terminal = alacritty;
    };
  };
}
