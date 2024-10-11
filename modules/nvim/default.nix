{
  impurity,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = [pkgs.neovim];
  environment.variables.EDITOR = "nvim";

  home-manager.users.${username} = {
    xdg.configFile."nvim/init.lua".source = impurity.link ./init.lua;
  };
}
