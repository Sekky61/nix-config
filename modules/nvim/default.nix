{
  pkgs,
  username,
  impurity,
  ...
}@args:
let
  # systems without impurity will use the identity
  link = if builtins.hasAttr "impurity" args then args.impurity.link else x: x;
in
# link = impurity.link;
{
  environment.systemPackages = [ pkgs.neovim ];
  environment.variables.EDITOR = "nvim";

  home-manager.users.${username} = {
    xdg.configFile."nvim".source = impurity.link ./.;
  };
}
