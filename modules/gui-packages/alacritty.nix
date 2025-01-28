{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    alacritty
    # other system-wide packages...
  ];

  home-manager.users.${username} = _: {
    programs.alacritty = {
      enable = true;
      settings = {
        keyboard.bindings = [
          # Clone window with the same CWD
          {
            key = "N";
            mods = "Control|Shift";
            action = "CreateNewWindow";
          }
        ];
        font = {
          # Font names can be a mess, but this one is tested, working
          normal = {family = "MonaspiceNe Nerd Font Mono";};
        };
        window.opacity = 0.94;
      };
    };
  };
}
