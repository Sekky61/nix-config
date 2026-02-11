{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.claude-code;
  dev_cfg = config.michal.dev;
in {
  options.michal.programs.claude-code = {
    enable = mkEnableOption "Claude Code";
  };

  config = mkMerge [
    (mkIf dev_cfg.enable {
      michal.programs.claude-code.enable = mkDefault true;
    })

    (mkIf cfg.enable {
      home-manager.users.${username} = {
        programs.bash.shellAliases.cc = "claude";
        programs.claude-code.enable = true;
      };
    })
  ];
}
