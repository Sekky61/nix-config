{
  pkgs,
  username,
  config,
  ...
}: let
  userCfg = config.home-manager.users.${username};
  programEnabled = name: userCfg.programs.${name}.enable == true;
  # defined if program name is enabled
  programAlias = name:
    if programEnabled name
    then name
    else null;
in {
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
    gh
    lazygit

    btop
    ripgrep
    unzip
    fd
    fzf
    socat
    jq
    gojq
    ethtool # network controls
    traceroute
    whois
    home-assistant-cli

    ueberzugpp # image support for terminals

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
        extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
      };
      eza = {
        enable = true;
        enableBashIntegration = true;
        icons = "auto";
        extraOptions = [
          "--almost-all"
          "--mounts"
        ];
      };
      nix-index = {
        # Create index with `nix-index`, then `nix-locate pattern` (for example `nix-locate bin/zig`)
        enable = true;
        enableBashIntegration = true;
      };
      yazi = {
        enable = true;
        enableBashIntegration = true;
        shellWrapperName = "y";
        settings.yazi = {
          manager = {
            layout = [
              1
              4
              3
            ];
            sort_by = "natural";
            sort_sensitive = true;
            sort_reverse = false;
            sort_dir_first = true;
            linemode = "none";
            show_hidden = true;
            show_symlink = true;
          };

          preview = {
            image_filter = "lanczos3";
            image_quality = 90;
            tab_size = 1;
            max_width = 600;
            max_height = 900;
            cache_dir = "";
            ueberzug_scale = 1;
            ueberzug_offset = [
              0
              0
              0
              0
            ];
          };

          tasks = {
            micro_workers = 5;
            macro_workers = 10;
            bizarre_retry = 5;
          };
        };
      };
    };
  };
}
