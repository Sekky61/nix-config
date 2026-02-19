{
  pkgs,
  username,
  impurity,
  ...
}: let
  nvim = pkgs.michal-unstable.neovim-unwrapped;
in {
  # have it truly everywhere
  environment.systemPackages = [nvim];

  home-manager.users.${username} = {
    xdg.configFile."nvim".source = impurity.link ./.; # TODO leave out the nix files

    programs.neovim = {
      enable = true;
      package = nvim;
      defaultEditor = true;
    };
  };
}
