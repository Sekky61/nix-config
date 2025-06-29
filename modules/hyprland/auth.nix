{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.michal.programs.polkit;
  inherit (lib) mkEnableOption mkIf mkOption types optional;
in {
  # Polkit popup (ssh key auth)
  # Source: https://github.com/webflo-dev/nixos/blob/724daa1359b419df4c1f8521191fb594555018d7/modules/home-manager/webflo/programs/polkt.nix

  options.michal.programs.polkit = {
    enable = mkEnableOption "programs - polkit";
    enableHyprlandIntegration = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    security.polkit.enable = true;

    home-manager.users.${username} = {
      home.packages = with pkgs; [
        hyprpolkitagent
      ];

      wayland.windowManager.hyprland.settings.exec-once =
        optional cfg.enableHyprlandIntegration
        "systemctl --user start hyprpolkitagent";
    };
  };
}
