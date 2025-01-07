{ inputs
, pkgs
, username
, config
, ...
}: {
  # nix
  documentation.nixos.enable = false; # .desktop
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-gaming.cachix.org"
      # Nixpkgs-Wayland
      "https://cache.nixos.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://nix-community.cachix.org"
      # Nix-community
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      # Nixpkgs-Wayland
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      # Nix-community
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.settings.trusted-users = [ "@wheel" ];

  # virtualisation
  # programs.virt-manager.enable = true;
  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
    virtualbox.guest.dragAndDrop = true;
  };
  users.extraGroups.vboxusers.members = [ "michal" ];

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

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  security = {
    rtkit.enable = true; # related to sound
    polkit.enable = true;
  };

  # dconf
  programs = {
    ssh = {
      extraConfig = ''
        Host riscvsim-droplet
            HostName 164.92.130.132
            User riscvsim
            IdentityFile ~/.ssh/id_rsa
      '';
    };
    gnupg = {
      # ssh passwords
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    wireshark.enable = true; # sets the group and whatnot
    dconf.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    firefox = {
      enable = true;
      nativeMessagingHosts.packages = [ pkgs.plasma5Packages.plasma-browser-integration ];
    };
    # Run dynamically linked stuff
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs
        # here, NOT in environment.systemPackages
      ];
    };
    kdeconnect.enable = true;
  };
  # packages
  environment = {
    localBinInPath = true;
    systemPackages = with pkgs; [
      inputs.iio-hyprland.packages.${pkgs.system}.default
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
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];
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

  # network
  networking = {
    networkmanager.enable = true;
  };
  services.resolved.enable = true; # Fix for no connection when tailscale is on


  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.sensor.iio.enable = true;

  # cross-compilation
  boot.binfmt.emulatedSystems = [ "i686-linux" "aarch64-linux" ];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  # Boot
  boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "btrfs" "ext4" "fat32" "ntfs" ];
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      efi.canTouchEfiVariables = true;
    };
    # kernelPackages = pkgs.linuxPackages_xanmod_latest;
    # kernelPatches = [{
    #   name = "enable RT_FULL";
    #   patch = null;
    #   # TODO: add realtime patch: PREEMPT_RT y
    #   extraConfig = ''
    #     PREEMPT y
    #     PREEMPT_BUILD y
    #     PREEMPT_VOLUNTARY n
    #     PREEMPT_COUNT y
    #     PREEMPTION y
    #   '';
    # }];
    # extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    # kernelModules = [ "acpi_call" ];
    # make 3.5mm jack work
    # extraModprobeConfig = ''
    #   options snd_hda_intel model=headset-mode
    # '';
  };

  system.stateVersion = "24.05";
}
