{
  lib,
  humanName ? execName,
  execName,
}:
with lib; {
  enable = mkEnableOption "${humanName} browser";
  default = mkEnableOption "${humanName} to be the default browser";
  name = mkOption {
    type = types.str;
    default = execName;
  };
  desktopFile = mkOption {
    type = types.str;
    default = "${execName}.desktop";
  };
}
