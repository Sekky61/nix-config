{
  config,
  pkgs,
  username,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.michal.graphical;

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
in {
  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.monaspace
        nerd-fonts.droid-sans-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        roboto
        twitter-color-emoji
        morewaita-icon-theme
        bibata-cursors
        rubik
        lexend
      ];
      fontconfig.defaultFonts = {
        serif = [
          "Georgia"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Roboto"
          "Noto Color Emoji"
        ];
        monospace = ["MonaspiceNe Nerd Font Mono"];
        emoji = ["Noto Color Emoji"];
      };
    };

    stylix.fonts = {
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

    home-manager.users.${username} = {
      home.packages = with pkgs; [
        font-manager
        # themes
        adwaita-qt6
        adwaita-icon-theme
        adw-gtk3
        material-symbols
        google-fonts
        moreWaita
        bibata-cursors
      ];
      home.file = {
        ".local/share/icons/MoreWaita" = {
          source = "${moreWaita}/share/icons";
        };
      };
    };
  };
}
