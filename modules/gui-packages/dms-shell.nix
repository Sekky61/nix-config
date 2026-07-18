{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.programs.dms-shell;
in {
  options.michal.programs.dms-shell = {
    enable = mkEnableOption "DankMaterialShell";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      imagemagick
      img2pdf
      tesseract
      zbar
    ];

    # DMS stores GUI-managed shell settings in
    # ~/.config/DankMaterialShell/settings.json. For example, enabling
    # fingerprint unlock for the DMS lock screen writes `enableFprint = true`.
    programs.dms-shell = {
      enable = true;
      plugins.quickCapture.src = pkgs.fetchFromGitHub {
        owner = "hthienloc";
        repo = "dms-quick-capture";
        rev = "v3.1.0";
        hash = "sha256-S7zQyE7HKVQY0o6Ncs3610ibgA21vRP+84INASABXt4=";
      };
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
