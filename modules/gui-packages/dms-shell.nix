{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.dms-shell;
in {
  options.michal.programs.dms-shell = {
    enable = mkEnableOption "DankMaterialShell";
  };

  config = mkIf cfg.enable {
    programs.dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
