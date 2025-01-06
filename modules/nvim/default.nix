{
  pkgs,
  username,
  impurity,
  ...
}:
{
  environment.systemPackages = with pkgs; [ neovim ]; # have it truly everywhere

  home-manager.users.${username} = {
    xdg.configFile."nvim".source = impurity.link ./.; # TODO leave out the nix files

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
