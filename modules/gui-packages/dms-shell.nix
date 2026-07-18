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
      # Dependencies for dms-quick-capture
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

    michal.programs.hyprland.keybinds = let
      # param mode: default, region, full, all, output, window, last, scroll
      # param 2: edit or float - float did not work
      quickCapture = mode: "dms ipc call quickCapture screenshot ${mode} edit";
    in [
      {
        description = "Capture and edit screenshot region";
        bind = [
          {
            mods = ["SUPER"];
            key = "S";
          }
          {key = "Print";}
        ];
        command = {exec = quickCapture "region";};
      }
      {
        description = "Capture and edit full screen";
        bind = {
          mods = ["SUPER" "ALT"];
          key = "S";
        };
        command = {exec = quickCapture "full";};
      }
    ];
  };
}
