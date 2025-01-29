{
  username,
  lib,
  impurity,
  ...
}: {
  home-manager.users.${username} = {
    # It should be in PATH. The PATH situation in nix is a mess.
    home.file.".local/bin".source = impurity.link ./scripts;
  };

  environment.localBinInPath = true;
}
