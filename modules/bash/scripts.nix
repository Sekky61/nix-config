{ username, impurity, ... }@args:
let
  # TODO: extract into utils
  link = if builtins.hasAttr "impurity" args then args.impurity.link else x: x;
in
{

  home-manager.users.${username} = {
    # It should be in PATH. The PATH situation in nix is a mess.
    home.file.".local/bin".source = link ./scripts;
  };

  environment.localBinInPath = true;
}
