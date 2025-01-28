{
  home-manager,
  username,
  ...
}: {
  home-manager.users.${username} = _: {
    home.file = {
      ".config/wallpapers".source = ./wallpapers;
    };
  };
}
