{
  pkgs,
  username,
  ...
}:
let
  homeDirectory = "/home/${username}";
in
{
  imports = [
    ## Dotfiles (manual)
    ./dotfiles.nix
    # Stuff
    ../../modules/gui-packages/ags
    ./dconf.nix
    ./mimelist.nix
    ./theme.nix
    ./git.nix
    ./java.nix

  ];

  home = {
    inherit username homeDirectory;
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  xdg.userDirs = {
    createDirectories = true;
  };

  gtk = {
    font = {
      name = "Rubik";
      package = pkgs.google-fonts.override { fonts = [ "Rubik" ]; };
      size = 11;
    };
  };

  programs = {
    home-manager.enable = true;
  };
  # this must be the version at which you have started using home-manager
  home.stateVersion = "23.11";
}
