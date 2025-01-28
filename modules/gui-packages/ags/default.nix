{
  inputs,
  pkgs,
  impurity,
  ...
}: let
  astalPkgs = inputs.ags.packages.${pkgs.system};

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
    pywal
    sassc
    (python311.withPackages (p: [
      p.material-color-utilities
      p.pywayland
    ]))
  ];

  pkgsExtraAgs = with pkgs; [
    gtksourceview
    gtksourceview4
    python311Packages.material-color-utilities
    python311Packages.pywayland
    pywal
    sassc
    webkitgtk
    webp-pixbuf-loader
    ydotool
  ];
in {
  imports = [inputs.ags.homeManagerModules.default];

  # config generated with `ags init --gtk 3 --directory "./modules/gui-packages/ags/config/"`

  # Can be ran (developed) with:
  # `ags run --directory ~/Documents/nix-config/modules/gui-packages/ags/config`
  #
  # - Do not use path relative to CWD
  programs.ags = {
    enable = true;

    # symlink to ~/.config/ags
    configDir = impurity.link ./config;

    # additional packages to add to gjs's runtime
    extraPackages = astalRuntimePkgs ++ pkgsExtraAgs;
  };

  home.packages = astalRuntimePkgs;
}
