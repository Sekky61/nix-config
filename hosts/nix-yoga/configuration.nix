{
  inputs,
  pkgs,
  username,
  config,
  nixos-hardware,
  ...
}: {
  # nix
  documentation.nixos.enable = false; # .desktop
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = true;
  };

  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-yoga-7-14ARH7-amdgpu
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  nix.settings.trusted-users = ["@wheel"];

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
    desktopManager.gnome.enable = {
      enable = true;
      extraGSettingsOverridePackages = [
        pkgs.nautilus-open-any-terminal
      ];
    };
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
    ];
  };

  # ZRAM
  zramSwap.enable = true;
  # zramSwap.memoryPercent = 100;

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
