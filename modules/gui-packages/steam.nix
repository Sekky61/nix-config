{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.steam;
in {
  options.michal.programs.steam = {
    enable = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
}
