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
    # DMS stores GUI-managed shell settings in
    # ~/.config/DankMaterialShell/settings.json. For example, enabling
    # fingerprint unlock for the DMS lock screen writes `enableFprint = true`.
    programs.dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
