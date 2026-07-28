{
  username,
  impurity,
  ...
}: {
  home-manager.users.${username} = {
    # It should be in PATH. The PATH situation in nix is a mess.
    home.file.".local/bin/enable-debug".source = impurity.link ./scripts/enable-debug;
  };

  environment.localBinInPath = true;
}
