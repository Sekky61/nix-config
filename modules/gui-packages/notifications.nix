{username, ...}: {
  home-manager.users.${username} = {
    services.mako = {
      enable = true;
      settings = {
        width = 300;
        height = 100;
        icons = true;
        margin = "10";
        padding = "8";
        border-size = 3;
        border-radius = 5;
        default-timeout = 7000;
      };
      extraConfig = ''
        # Colors

        background-color=#303446
        text-color=#c6d0f5
        border-color=#a6d189
        progress-color=over #414559

        [urgency=high]
        border-color=#ef9f76
      '';
    };
  };
}
