{
  lib,
  inputs,
  ...
}:
with lib; let
  themeJson = builtins.fromJSON (readFile ./theme.json);
  # baseCss = config.lib.stylix.colors { # Handlebars formatting
  #   template = ./gtk_template.json;
  #   extension = "css";
  # };
in {
  options.michal.theme = mkOption {
    type = with types; attrsOf str;
    default = {};
    description = ''
      Keyed colors. Assume #RRGGBB. Names like primary, surface.
    '';
    example = {
      primary = "#8dcdff";
      outline = "#8b9198";
      error = "#ffb4a9";
    };
  };

  imports = [
    inputs.stylix.nixosModules.stylix
    ./graphical.nix
  ];

  config = {
    stylix = {
      enable = true;
      autoEnable = false; # conflicts with impure configs
      base16Scheme = with themeJson; {
        # Hyprland: background
        # Chrome: theme
        base00 = surface;
        base01 = background;
        base02 = primaryContainer;
        # Hyprland: Inactive border
        base03 = secondaryContainer;
        base04 = onPrimary;
        # Default foreground
        base05 = onSurface;
        base06 = onBackground;
        base07 = primary;
        base08 = error; #error
        base09 = tertiary;
        base0A = onPrimaryContainer;
        base0B = onSecondaryContainer;
        base0C = onTertiaryContainer;
        # Hyprland: Active border
        base0D = primary;
        base0E = onSecondary;
        base0F = primary;
      };
      polarity = "dark";
      opacity.terminal = 0.9;
      targets = {
        console.enable = false;
      };
    };

    michal.theme = themeJson;
  };
}
