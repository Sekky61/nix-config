{
  pkgs,
  username,
  config,
  ...
}:
let
  userCfg = config.home-manager.users.${username};
  programEnabled = name: userCfg.programs.${name}.enable == true;
  # defined if program name is enabled
  programAlias = name: if programEnabled name then name else null;
in
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
        shellAliases = {
          cat = programAlias "bat";
        };
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
      bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
      };
      eza = {
        enable = true;
        enableBashIntegration = true;
        icons = "auto";
      };
      nix-index = {
        # Create index with `nix-index`, then `nix-locate pattern` (for example `nix-locate bin/zig`)
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
