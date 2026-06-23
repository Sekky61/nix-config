{
  pkgs,
  username,
  impurity,
  ...
}: let
  nvim = pkgs.michal-unstable.neovim-unwrapped;
in {
  # have it truly everywhere
  environment.systemPackages = [
    nvim
    pkgs.tree-sitter # treesitter plugin uses tree-sitter-cli
  ];

  home-manager.users.${username} = {
    xdg.configFile."nvim/lua".source = impurity.link ./lua;
    xdg.configFile."nvim/lazy-lock.json".source = impurity.link ./lazy-lock.json;
    xdg.configFile."nvim/.luarc.json".source = impurity.link ./.luarc.json;

    programs.neovim = {
      enable = true;
      package = nvim;
      defaultEditor = true;
      withRuby = true;
      withPython3 = true;
      initLua = builtins.readFile ./init.lua;
    };
  };

  environment.shellAliases = {
    v = "nvim";
  };
}
