{
  pkgs,
  username,
  ...
} @ args: let
  # systems without impurity will use the identity
  link =
    if builtins.hasAttr "impurity" args
    then args.impurity.link
    else x: x;
  # link = impurity.link;
in {
  environment.systemPackages = [pkgs.neovim];
  environment.variables.EDITOR = "nvim";

  home-manager.users.${username} = {
    xdg.configFile."nvim/init.lua".source = link ./init.lua;
  };
}
