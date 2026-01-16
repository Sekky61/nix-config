{
  inputs,
  username,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.walker;
  walkerBin = "${pkgs.walker}/bin/walker";
in {
  options.michal.programs.walker = {
    enable = mkEnableOption "walker application launcher";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      imports = [inputs.walker.homeManagerModules.default];

      # app launcher
      # Docs: https://github.com/abenz1267/walker/pulls?tab=readme-ov-file#3-configure-walker
      programs.walker = {
        enable = true;
        runAsService = true;
      };

      wayland.windowManager.hyprland = {
        settings = {
          gesture = [
            "4, down, dispatcher, exec, ${walkerBin}"
          ];
        };
      };
    };

    michal.programs.hyprland.keybinds = [
      {
        description = "Launch application launcher";
        bind = {
          mods = ["SUPER"];
          key = "Space";
        };
        command = {params = walkerBin;};
      }
    ];
  };
}
