{
  pkgs,
  username,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    btop # Resource monitor
    jq # Pretty-print and work with json
    ripgrep # fuzzy finder
    unzip # unzip zip files
    fd # find
    fzf # fuzzy finder, needed by a script and nvim telescope plugin
    home-assistant-cli # smart home
    ueberzugpp # image support for terminals
  ];

  home-manager.users.${username} = {
    programs = {
      bash = {
        enable = true;
        enableCompletion = true; # needed for bashIntegrations
        shellAliases = let
          userCfg = config.home-manager.users.${username};
          programEnabled = name: userCfg.programs.${name}.enable == true;
          # defined if program name is enabled
          programAlias = name:
            if programEnabled name
            then name
            else null;
        in {
          cat = programAlias "bat";
        };
      };
      atuin = {
        enable = true;
        enableBashIntegration = true;
        # Does not work on WSL, todo enable it for sync
        #daemon.enable = true;
        settings = {
          enter_accept = true;
          # key_path = config.sops.secrets."atuin_key".path;
        };
      };
      zoxide = {
        # zi for interactive mode
        enable = true;
        enableBashIntegration = true;
      };
      bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
        config = {
          style = "-numbers,-grid"; # Do not show line numbers and grid
        };
      };
      eza = {
        enable = true;
        enableBashIntegration = true;
        git = true;
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
        settings = {
          mgr = {
            layout = [
              1
              2
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
            wrap = "yes";
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
