{
  config,
  inputs,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.handy;
in {
  options.michal.programs.handy = {
    enable = mkOption {
      type = types.bool;
      default = config.michal.programs.stt.enable;
      description = "Handy speech-to-text service";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {config, ...}: {
      imports = [inputs.handy.homeManagerModules.default];

      services.handy.enable = true;
      home.packages = [config.services.handy.package];
    };
  };
}
