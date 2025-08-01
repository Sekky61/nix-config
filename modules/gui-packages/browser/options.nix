{
  lib,
  humanName ? execName,
  execName,
  package ? null,
  desktopFileName ? package.meta.desktopFile,
}:
with lib; {
  enable = mkEnableOption "${humanName} browser";
  default = mkEnableOption "${humanName} to be the default browser";
  name = mkOption {
    type = types.str;
    default = execName;
  };
  desktopFileName = mkOption {
    type = types.str;
    default = desktopFileName;
  };
}
