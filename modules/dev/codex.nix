{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.codex;
  dev_cfg = config.michal.dev;
in {
  options.michal.programs.codex = {enable = mkEnableOption "Codex";};

  config = mkMerge [
    (mkIf dev_cfg.enable {michal.programs.codex.enable = mkDefault true;})

    (mkIf cfg.enable {
      home-manager.users.${username}.programs.codex.enable = true;
    })
  ];
}
