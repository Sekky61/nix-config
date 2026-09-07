{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.three-d-printing;
in {
  options.michal.programs.three-d-printing = {
    enable = mkEnableOption "3D printing software";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      freecad
      orca-slicer
    ];

    users.users.${username}.extraGroups = ["dialout"];
  };
}
