{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.hunk;
in {
  options.michal.programs.hunk = {
    enable = mkEnableOption "Hunk";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      imports = [inputs.hunk.homeManagerModules.default];

      programs.hunk = {
        enable = true;
        package = inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.hunk;
      };
    };
  };
}
