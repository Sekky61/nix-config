{
  pkgs,
  username,
  ...
}:
{
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
        window.opacity = 0.94;
      };
    };
  };
}
