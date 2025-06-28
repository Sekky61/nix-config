{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.michal.programs.unity;
in {
  options.michal.programs.unity = {
    enable = lib.mkEnableOption "Unity";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unityhub
      (
        with dotnetCorePackages;
          combinePackages [
            sdk_6_0
            sdk_7_0
          ]
      )
    ];

    environment.variables.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
  };
}
