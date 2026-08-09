{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.handy;
  handyBacklog = pkgs.writeShellScriptBin "handy-backlog" (builtins.readFile ../bash/scripts/handy-backlog);
in {
  options.michal.programs.handy = {
    enable = mkOption {
      type = types.bool;
      default = config.michal.graphical.enable;
      description = "Handy speech-to-text service";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {config, ...}: {
      imports = [inputs.handy.homeManagerModules.default];

      services.handy.enable = true;
      home.packages = [config.services.handy.package handyBacklog];
    };

    michal.programs.hyprland.keybinds = [
      {
        description = "Handy push to talk with post-processing";
        bind = {
          mods = ["SUPER"];
          key = "Z";
        };
        command = {exec = "handy --start-recording --post-process";};
      }
      {
        description = "Handy push to talk with post-processing";
        bind = {
          mods = ["SUPER"];
          key = "Z";
        };
        command = {
          exec = "handy --stop-recording";
          flags = ["release"];
        };
      }
      {
        description = "Add voice note to backlog";
        bind = {
          mods = ["SUPER"];
          key = "B";
        };
        command = {exec = "${handyBacklog}/bin/handy-backlog";};
      }
      {
        description = "Add voice note to backlog";
        bind = {
          mods = ["SUPER"];
          key = "B";
        };
        command = {
          exec = "handy --stop-recording";
          flags = ["release"];
        };
      }
    ];
  };
}
