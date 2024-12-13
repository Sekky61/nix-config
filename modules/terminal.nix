{
  pkgs,
  username,
  ...
}:
{
  # This is the base to have at every vm, server or pc
  imports = [
    ./nvim
    ./bash
  ];

  # ---- System Configuration ----
  programs = {
    htop.enable = true;
    mtr.enable = true; # todo
  };

  environment.systemPackages = with pkgs; [
    git
    btop
    gh
    ripgrep
    unzip
    zoxide
    atuin # shell history
    bat
    eza
    fd
    fzf
    socat
    jq
    gojq
    lazygit
    ethtool # network controls
    traceroute

    fancy-motd
  ];
}
