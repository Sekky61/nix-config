{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.t3code;
  dev_cfg = config.michal.dev;
in {
  options.michal.programs.t3code = {
    enable = mkEnableOption "T3 Chat";
  };

  config = mkMerge [
    (mkIf dev_cfg.enable {
      michal.programs.t3code.enable = mkDefault true;
    })

    (mkIf cfg.enable {
      home-manager.users.${username}.home.packages = [
        inputs.t3code.packages.${pkgs.system}.default
      ];
    })
  ];
}
