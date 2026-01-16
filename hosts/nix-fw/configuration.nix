{
  inputs,
  pkgs,
  username,
  config,
  ...
}: {
  # nix
  documentation.nixos.enable = false; # .desktop
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = true;
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
    # todo activation scripts failed and prevented an update
    # virtualbox.host.enable = true;
    # virtualbox.guest.dragAndDrop = true;
  };
  users.extraGroups.vboxusers.members = ["michal"];

  # Increase limits
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576; # default: 8192
    "fs.inotify.max_user_instances" = 1024; # default: 128
    "fs.inotify.max_queued_events" = 32768; # default: 16384 };
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
          command = ''${pkgs.tuigreet}/bin/tuigreet --greeting 'The royal PC is clean, your Highness' --user-menu --asterisks --time --remember --cmd start-hyprland --kb-command 1 --kb-sessions 2 --kb-power 3'';
          user = "greeter";
        };
      };
    };
    gvfs.enable = true;
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
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

      # debug wifi
      wirelesstools
      iw
    ];
  };

  # ZRAM
  zramSwap.enable = true;
  # zramSwap.memoryPercent = 100;

  # i got to the web interface at http://localhost:631/admin
  # and when it asked for login i did a michal/mypassword
  services.printing.enable = true;
  services.printing.drivers = [pkgs.gutenprint];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # logind
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };
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
    # wireless.enable = true;

    # interfaces = {
    #   wlan0.useDHCP = true;
    # };
  };

  services.resolved.enable = true; # Fix for no connection when tailscale is on

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # The programs.iio-hyprland.enable should be enough, but i didnt delete this
  hardware.sensor.iio.enable = true;

  # cross-compilation
  boot.binfmt.emulatedSystems = ["i686-linux" "aarch64-linux"];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  # Boot
  boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = ["btrfs" "ext4" "fat32" "ntfs"];
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Framework specific

  # Firmware
  # https://github.com/fwupd/fwupd
  # `fwupdmgr get-updates`
  # `fwupdmgr update`
  services.fwupd.enable = true;

  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  # Enrollment: `fprintd-enroll`
  services.fprintd = {
    enable = true;
  };

  system.stateVersion = "24.05";
}
