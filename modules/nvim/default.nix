{
  pkgs,
  username,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [neovim]; # have it truly everywhere

  home-manager.users.${username} = {
    xdg.configFile."nvim".source = lib.michal.link ./.; # TODO leave out the nix files

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
