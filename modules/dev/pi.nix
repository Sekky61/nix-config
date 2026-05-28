{
  config,
  inputs,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.pi;
  dev_cfg = config.michal.dev;
in {
  options.michal.programs.pi = {
    enable = mkEnableOption "Pi coding agent";
  };

  config = mkMerge [
    (mkIf dev_cfg.enable {
      michal.programs.pi.enable = mkDefault true;
    })

    (mkIf cfg.enable {
      home-manager.users.${username} = {
        imports = [inputs.pi.homeManagerModules.default];

        programs.pi.coding-agent.enable = true;
      };
    })
  ];
}
