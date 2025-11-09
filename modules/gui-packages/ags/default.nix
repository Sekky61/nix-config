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
    environment.systemPackages = let
      # TODO fix, ags.lib api changed
      # ags-bar = inputs.ags.lib.bundle {
      #   inherit pkgs extraPackages;
      #   src = ./config;
      #   name = "ags-bar";
      # };
      # ags-bar = pkgs.stdenv.mkDerivation {
      #   pname = "ags-bar";
      #
      #   src = ./config;
      #
      #   nativeBuildInputs = with pkgs; [
      #     wrapGAppsHook3
      #     gobject-introspection
      #     ags.packages.${system}.default
      #   ];
      #
      #   buildInputs = [
      #     pkgs.glib
      #     pkgs.gjs
      #     astal.io
      #     astal.astal4
      #     # packages like astal.battery or pkgs.libsoup_4
      #   ];
      #
      #   installPhase = ''
      #     ags bundle app.ts $out/bin/my-shell
      #   '';
      #
      #   preFixup = ''
      #     gappsWrapperArgs+=(
      #       --prefix PATH : ${pkgs.lib.makeBinPath [
      #       # runtime executables
      #     ]}
      #     )
      #   '';
      # };
    in
      with pkgs; [
        # ags-bar
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
  };
}
