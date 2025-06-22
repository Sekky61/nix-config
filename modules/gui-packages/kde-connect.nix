{
  username,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.kde-connect;
  package = pkgs.kdePackages.kdeconnect-kde;
  # or pkgs.gnomeExtensions.gsconnect;
  # or pkgs.valent;
in {
  options.michal.programs.kde-connect = {
    enable = mkEnableOption "kde-connect";
  };

  config = mkIf cfg.enable {
    # NixOS module just opens ports 1714-1764 tcp/udp
    programs.kdeconnect = {
      inherit package;
      enable = true;
    };

    # home-manager starts systemd service
    home-manager.users.${username} = {
      services.kdeconnect = {
        inherit package;
        enable = true;
        indicator = true;
      };
    };
  };
}
