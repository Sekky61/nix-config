# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./bash.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "michal";
    homeDirectory = "/home/michal";
  };

  home.packages = with pkgs; [
    zip
    xz
    unzip
    ripgrep
    jq
    eza
    fzf
    nmap
    bat
    zoxide
    eza
    thefuck
    htop
    powertop
    rnote

    file
    which
    tree
    acpi # battery
    rofi # window switcher
    dunst # notifications
    libnotify # notify-send
    playerctl # play, pause
    xdotool # debug media keys

    nix-output-monitor
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "RobotoMono" ]; })
    cantarell-fonts # awesomewm font

    btop
    strace
    lsof

    google-chrome
    alacritty
    spotify
    spotifyd
    shutter

    clang_18
    gnumake

    nodejs_20 # Includes npm
  ];

  fonts.fontconfig.enable = true; # https://discourse.nixos.org/t/how-can-i-install-some-not-all-nerdfonts/43863/2

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Michal Majer";
    userEmail = "misa@majer.cz";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
  };
  xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings from TOML
    settings = builtins.fromTOML (builtins.readFile ../dotfiles/cfg/alacritty.toml);
  };

  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # Environment
  systemd.user.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "google-chrome-stable";
    TERMINAL = "alacritty";
  };

  home.file."awesome" = {
      source = ../dotfiles/awesome;
      target = "./.config/awesome";
      recursive = true;
    };
  
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
