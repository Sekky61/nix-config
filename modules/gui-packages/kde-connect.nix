# An alternative called gsconnect is available, but should be about the same
{
  username,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.kde-connect;
in {
  options.michal.programs.kde-connect = {
    enable = mkEnableOption "kde-connect";
  };

  config = mkIf cfg.enable {
    # NixOS module just opens ports 1714-1764 tcp/udp
    programs.kdeconnect.enable = true;

    # home-manager starts systemd service
    home-manager.users.${username} = {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
  };
}
