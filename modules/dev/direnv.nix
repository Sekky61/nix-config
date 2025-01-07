{
  # load flake development shell on cd
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # Note: to ignore the .envrc file in a git repo,
  # add the following to the .git/info/exclude file:
  # .envrc
}
