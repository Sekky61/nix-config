{pkgs, ...}: {
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
}
