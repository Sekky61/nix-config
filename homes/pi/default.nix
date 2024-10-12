{
  pkgs,
  username,
  ...
}: let
  homeDirectory = "/home/${username}";
in {
  programs = {
    home-manager.enable = true;
  };
  home.stateVersion = "23.11"; # this must be the version at which you have started using the program
}
