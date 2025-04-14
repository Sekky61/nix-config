{
  pkgs,
  username,
  ...
}: let
  homeDirectory = "/home/${username}";
in {
  imports = [
    ./dconf.nix
    ./mimelist.nix
    ./theme.nix
    ./git.nix
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

  programs = {
    home-manager.enable = true;
  };

  # this must be the version at which you have started using home-manager
  home.stateVersion = "23.11";
}
