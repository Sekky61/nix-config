{ username, impurity, ... }:
let
  link = impurity.link;
in
{

  home-manager.users.${username} = {
    # It should be in PATH. The PATH situation in nix is a mess.
    home.file.".local/bin".source = link ./scripts;
  };

  environment.localBinInPath = true;
}
