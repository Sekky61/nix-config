{
  config,
  inputs,
  pkgs,
  lib,
  impurity,
  ...
}: {
  xdg.configFile = let
    link = lib.michal.link;
  in {
    # These are the files that are symlinked to the configuration directory.
    # "ags".source = link ./config/ags;
    "fish".source = link ./config/fish;
    "foot".source = link ./config/foot;
    "fuzzel".source = link ./config/fuzzel;
  };
}
