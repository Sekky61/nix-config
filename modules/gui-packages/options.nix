{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options.michal.graphical = {
    enable = mkEnableOption "graphical environment";
  };
}