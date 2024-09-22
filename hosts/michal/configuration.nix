{
  inputs,
  pkgs,
  username,
  config,
  ...
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

  # virtualisation
  # programs.virt-manager.enable = true;
  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
    virtualbox.guest.dragAndDrop = true;
  };
  users.extraGroups.vboxusers.members = ["michal"];

  services = {
    spice-vdagentd.enable = true; # protocol for sharing clipboard with VMs
    pcscd.enable = true; # necessary? for gnupg
    envfs.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
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

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
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
    rtkit.enable = true;
    polkit.enable = true;
    # pam.services.swaylock = { };
    # pam.services.swaylock-effects = {};
  };

  # dconf
  programs = {
    ssh = {
      extraConfig = ''
        Host rpi
            HostName 192.168.0.200
            User majerpi
            IdentityFile ~/.ssh/id_rsa

        Host rpi-wifi
            HostName 192.168.0.201
            User majerpi
            IdentityFile ~/.ssh/id_rsa

        Host rpi-zerotier
            HostName 10.242.204.103
            User majerpi
            IdentityFile ~/.ssh/id_rsa

        Host sc-nas.fit.vutbr.cz
            HostName sc-nas.fit.vutbr.cz
            User xmajer21
            IdentityFile ~/.ssh/id_ed25519
            ForwardAgent yes

        Host sc-gpu1
            HostName sc-gpu1.fit.vutbr.cz
            User xmajer21
            ForwardAgent yes

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
      nativeMessagingHosts.packages = [pkgs.plasma5Packages.plasma-browser-integration];
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
    ];
  };

  # ZRAM
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

  # logind
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
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
        "wheel"
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
    hostName = "michalyoga";
    networkmanager.enable = true;
  };

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.sensor.iio.enable = true;

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
