{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.graphical;
in {
  config = mkIf cfg.enable {
    stylix = {
      image = ../../assets/wallpapers/spyxfamily.png;
      targets = {
        grub = {
          enable = true;
          useImage = true;
        };
      };
    };
    home-manager.users.${username} = {
      stylix.targets = {
        hyprland.enable = true;
        hyprland.hyprpaper.enable = true;
        hyprlock.enable = false;
        alacritty.enable = false;
        vscode.enable = false;
        gtk.enable = false;
      };

      gtk = {
        enable = true;
        font = {
          name = "Roboto";
          size = 12; # This size directs size of text in UI (bar, settings)
        };
        # theme.name = gtk-theme;

        # Below is untested/unknown
        cursorTheme = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
        };
        iconTheme.name = "MoreWaita";
        # gtk3.extraCss = ''
        #   headerbar, .titlebar,
        #   .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
        #     border-radius: 0;
        #   }
        # '';
      };

      qt = {
        enable = true;
        platformTheme.name = "kde6";
      };
    };
  };
}
