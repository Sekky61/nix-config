{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
with lib;
let
  cfg = config.michal.theme;

  themeJson = builtins.fromJSON (readFile ./theme.json);

  # baseCss = config.lib.stylix.colors { # Handlebars formatting
  #   template = ./gtk_template.json;
  #   extension = "css";
  # };
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

  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = {
    stylix = {
      enable = true;
      autoEnable = true;
      image = ../../assets/wallpapers/spyxfamily.png;
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
        grub = {
          enable = true;
          useImage = true;
        };
      };
      fonts = {
        serif = {
          package = pkgs.roboto-serif;
          name = "Roboto Serif";
        };

        sansSerif = {
          package = pkgs.roboto;
          name = "Roboto";
        };

        monospace = {
          package = pkgs.nerd-fonts.monaspace;
          name = "Monaspace Neon";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
    home-manager.users.${username} = _: {
      # Some of stylix only in Home-manager
      stylix.targets = {
        # Explicitly say what to style. Default is false with autoEnable = false
        hyprland.enable = true;
        hyprland.hyprpaper.enable = true;
        hyprlock.enable = false;
        alacritty.enable = false;
        vscode.enable = false;
        gtk.enable = false;
      };

      # xdg.configFile = {
      #   "gtk-3.0/gtk.css".source = baseCss;
      #   "gtk-4.0/gtk.css".source = baseCss;
      # };
    };

    michal.theme = themeJson;
  };
}
