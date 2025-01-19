{
  config,
  pkgs,
  lib,
  username,
  ...
}:
with lib;
let
  cfg = config.michal.theme;

  themeJson = builtins.fromJSON (readFile ./theme.json);
in
{
  options.michal.theme = mkOption {

      type = with types; attrsOf str;
      default =  {};
      description = ''
        Keyed colors. Assume #RRGGBB. Names like primary, surface.
      '';
      example = {
        primary = "#8dcdff";
        outline = "#8b9198";
        error = "#ffb4a9";
      };
  };

  config = {
    michal.theme = themeJson;
  };
}
