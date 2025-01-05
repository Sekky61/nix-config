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
    mtr.enable = true; # todo alias (my trace route)
  };

  environment.systemPackages = with pkgs; [
    git
    btop
    gh
    ripgrep
    unzip
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
    whois
    home-assistant-cli

    # fancy-motd # greet, welcome message
  ];


  home-manager.users.${username} = {
    programs = {
      bash = {
        enable = true;
        enableCompletion = true; # needed for bashIntegrations
      };
      atuin = {
        enable = true;
        enableBashIntegration = true;
        daemon.enable = true; # todo sync
        settings = {
          enter_accept = true;
        };
      };
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };
      nix-index = {
        # Create index with `nix-index`, then `nix-locate pattern` (for example `nix-locate bin/zig`)
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
