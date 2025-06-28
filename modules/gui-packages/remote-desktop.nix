{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.remote-desktop;
in {
  options.michal.programs.remote-desktop = {
    enable = mkEnableOption "the remote desktop program";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      moonlight-qt
    ];
    services.sunshine = {
      enable = true;
      autoStart = false;
      openFirewall = true;
    };
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;
    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };
  };
}
