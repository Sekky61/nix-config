{
  inputs,
  pkgs,
  username,
  lib,
  config,
  ...
}: {
  # nix
  documentation.nixos.enable = false; # .desktop
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = true;
  };

  imports = [
    # inputs.nixos-hardware.nixosModules.lenovo-yoga-7-14ARH7-amdgpu
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    docker-desktop.enable = true;
    interop.register = true;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  nix.settings.trusted-users = ["@wheel"];

  # virtualisation
  # programs.virt-manager.enable = true;
  virtualisation = {
    docker.enable = true;
  };

  services = {
    spice-vdagentd.enable = true; # protocol for sharing clipboard with VMs
    pcscd.enable = true; # necessary? for gnupg
    envfs.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          # F1 to open commands
          # F2 to open sessions
          # F3 to open power menu
          command = ''${pkgs.greetd.tuigreet}/bin/tuigreet --greeting 'The royal PC is clean, your Highness' --user-menu --asterisks --time --remember --cmd Hyprland --kb-command 1 --kb-sessions 2 --kb-power 3'';
          user = "greeter";
        };
      };
    };
    gvfs.enable = true;
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverridePackages = [
          pkgs.nautilus-open-any-terminal
        ];
      };
    };
  };

  # dconf
  programs = {
    gnupg = {
      # ssh passwords
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    wireshark.enable = true; # sets the group and whatnot
    dconf.enable = true;
    # Run dynamically linked stuff
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs
        # here, NOT in environment.systemPackages
      ];
    };
  };
  # packages
  environment = {
    localBinInPath = true;
    systemPackages = with pkgs; [
      curl
      bash
      fish
      git
      gh
      qemu
      quickemu
      # home-manager
      wget
      nixpkgs-fmt
      nixfmt-classic

      alsa-utils # audio debug (arecord -l)

      maven
    ];
  };

  # ZRAM
  # zramSwap.enable = true;
  # zramSwap.memoryPercent = 100;

  services.printing.enable = true;
  services.printing.drivers = [pkgs.gutenprint];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # logind
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=ignore
  '';
  # user
  users = {
    defaultUserShell = pkgs.bash;
    users.${username} = {
      # home = "/home/${username}";
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [
        "networkmanager"
        "wheel" # sudo
        "video"
        "input"
        "uinput"
        "libvirtd"
        "wireshark"
        "docker"
      ];
    };
  };

  services.resolved.enable = true; # Fix for no connection when tailscale is on

  # cross-compilation
  boot.binfmt.emulatedSystems = ["i686-linux" "aarch64-linux"];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05";
}
