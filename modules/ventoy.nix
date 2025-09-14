{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.ventoy;
  # sudo ventoy-web
  # or
  # ./scripts/ventoy-install
in {
  options.michal.programs.ventoy = {
    enable = mkEnableOption "ventoy";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ventoy-full
    ];

    # :(
    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-1.1.07"
    ];
  };
}
