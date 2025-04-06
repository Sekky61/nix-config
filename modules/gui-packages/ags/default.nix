{
  inputs,
  pkgs,
  username,
  impurity,
  ...
}: let
  # TODO revise packages
  # TODO move some to devshell
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
    pywal # generate colorschemes
    sassc # sass compiler
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

  extraPackages = astalRuntimePkgs ++ pkgsExtraAgs;
in {
  environment.systemPackages = let
    ags-bar = inputs.ags.lib.bundle {
      inherit pkgs extraPackages;
      src = ./config;
      name = "ags-bar";
    };
  in
    with pkgs; [
      ags-bar
      gtk3 # icon-library (probably)
    ];

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
      configDir = impurity.link ./config;

      # additional packages to add to gjs's runtime
      inherit extraPackages;
    };

    home.packages = astalRuntimePkgs;
  };
}
