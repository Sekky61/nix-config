{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./alacritty.nix
    ./fonts.nix
    ./nvim
    ./bash
  ];

  # ---- Home Configuration ----
  home-manager.users.${username} = {
    programs.git.enable = true;
  };

  # ---- System Configuration ----
  programs = {
    htop.enable = true;
    mtr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    btop
    gh
    playerctl
    ripgrep
    unzip
    zoxide

    # todo review
    vhs
    mods
  ];
}
