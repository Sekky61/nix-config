{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  # Source: https://github.com/outfoxxed/impurity.nix
  cfg = config.michal.impurity;

  relativePath = path:
    assert types.path.check path;
    with builtins; strings.removePrefix (toString cfg.configRoot) (toString path);

  impurePath = let
    impurePathEnv = builtins.getEnv "IMPURITY_PATH";
  in
    if impurePathEnv == ""
    then throw "impurity.enable is true but IMPURITY_PATH is not set"
    else impurePathEnv;

  createImpurePath = path: let
    relative = relativePath path;
    full = impurePath + relative;
  in
    config.home-manager.users.${username}.lib.file.mkOutOfStoreSymlink full;
in {
  options.michal.impurity = {
    enable = mkEnableOption "impurity (symlinks to config)";

    configRoot = mkOption {
      type = types.path;
      description = "The root of your nixos configuration";
    };
  };

  config._module.args.impurity = {
    link = path:
      if cfg.enable
      then createImpurePath path
      else path;
  };
}
