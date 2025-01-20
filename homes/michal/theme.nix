{
  pkgs,
  inputs,
  ...
}:
let
  gtk-theme = "adw-gtk3-dark";

  moreWaita = pkgs.stdenv.mkDerivation {
    name = "MoreWaita";
    src = inputs.more-waita;
    installPhase = ''
      mkdir -p $out/share/icons
      mv * $out/share/icons
    '';
  };

  google-fonts = pkgs.google-fonts.override {
    fonts = [
      # Sans
      "Gabarito"
      "Lexend"
      # Serif
      "Chakra Petch"
      "Crimson Text"
    ];
  };

  cursor-theme = "Bibata-Modern-Classic";
  cursor-package = pkgs.bibata-cursors;
in
{
  home = {
    packages = with pkgs; [
      # themes
      adwaita-qt6
      adw-gtk3
      material-symbols
      google-fonts
      moreWaita
      bibata-cursors
    ];
    file = {
      ".local/share/icons/MoreWaita" = {
        source = "${moreWaita}/share/icons";
      };
    };
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
      name = cursor-theme;
      package = cursor-package;
    };
    iconTheme.name = moreWaita.name;
    # gtk3.extraCss = ''
    #   headerbar, .titlebar,
    #   .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
    #     border-radius: 0;
    #   }
    # '';
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
  };
}
