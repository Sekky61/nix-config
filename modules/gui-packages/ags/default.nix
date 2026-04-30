{
  config,
  inputs,
  pkgs,
  username,
  impurity,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.programs.ags;

  # TODO revise packages
  # TODO move some to devshell
  astalPkgs = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system};

  astalRuntimePkgs = with astalPkgs;
    [
      battery
      apps
      auth
      bluetooth
      hyprland
      mpris
      network
      notifd
      powerprofiles
      tray
      wireplumber
    ]
    ++ pkgsExtra;

  pkgsExtra = with pkgs; [
    pywal # generate colorschemes
    sassc # sass compiler
  ];

  pkgsExtraAgs = with pkgs; [
    gtksourceview
    gtksourceview4
    libadwaita
    pywal
    sassc
    webkitgtk_6_0
    webp-pixbuf-loader
    ydotool
  ];

  extraPackages = astalRuntimePkgs ++ pkgsExtraAgs;
in {
  options.michal.programs.ags = {
    enable = mkEnableOption "ags gui";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      imports = [inputs.ags.homeManagerModules.default];

      # config generated with `ags init --gtk 3 --directory "./modules/gui-packages/ags/config/"`

      # Can be ran (developed) with:
      # `ags run --directory modules/gui-packages/ags/config`
      # or
      # `./scripts/dev-ags`
      programs.ags = {
        enable = true;
        # symlink to ~/.config/ags
        configDir = impurity.link ./config-v3;
        inherit extraPackages;
      };

      home.packages = astalRuntimePkgs;
    };
  };
}
