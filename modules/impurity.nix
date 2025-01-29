{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.impurity;
in {
  options.michal.impurity = {
    enable = mkEnableOption "impurity (symlinks to config)";
  };

  config._module.args.impurity = {
    link = path: path;
  };
}
