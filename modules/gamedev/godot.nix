{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.michal.programs.godot;
in {
  options.michal.programs.godot = {
    enable = lib.mkEnableOption "Godot";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      godot_4
    ];
  };
}
