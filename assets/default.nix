{username, ...}: {
  home-manager.users.${username} = {
    home.file = {
      ".config/wallpapers".source = ./wallpapers;
    };
  };
}
