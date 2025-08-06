{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.environment;
in {
  imports = [
    ./alacritty.nix
    ./ghostty.nix
  ];

  options.michal.environment.terminal = mkOption {
    type = with types; nullOr str;
    default = null;
    description = ''
      Default terminal emulator
    '';
  };

  config = {
    environment.sessionVariables = mkIf (cfg.terminal != null) {
      TERMINAL = cfg.terminal;
    };

    environment.systemPackages = with pkgs; [
      brightnessctl
      playerctl

      # todo review
      vhs
      mods
    ];
  };
}
