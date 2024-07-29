{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    alacritty
  ];

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
      window.opacity = 0.9;
    };
  };
}
