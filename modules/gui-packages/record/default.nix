{
  config,
  lib,
  username,
  impurity,
  ...
}:
with lib; let
  cfg = config.michal.programs.record;
in {
  options.michal.programs.record = {
    enable = mkOption {
      type = types.bool;
      default = config.michal.graphical.enable;
      description = "record script";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      # It should be in PATH. The PATH situation in nix is a mess.
      home.file.".local/bin/record".source = impurity.link ./record;
    };

    environment.localBinInPath = true;
  };
}
