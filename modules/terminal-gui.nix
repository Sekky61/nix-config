{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl
    playerctl

    # todo review
    vhs
    mods
  ];
}
