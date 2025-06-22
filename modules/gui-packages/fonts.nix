# Use font-manager to browse
{
  pkgs,
  username,
  ...
}: {
  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.monaspace
      nerd-fonts.droid-sans-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      roboto
      twitter-color-emoji
      morewaita-icon-theme
      bibata-cursors
      rubik
      lexend
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Georgia"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Roboto"
        "Noto Color Emoji"
      ];
      monospace = ["MonaspiceNe Nerd Font Mono"];
      emoji = ["Noto Color Emoji"];
    };
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      font-manager
    ];
  };
}
