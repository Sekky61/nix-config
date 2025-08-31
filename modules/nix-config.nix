{
  lib,
  inputs,
  username,
  ...
}: {
  # Source: https://nixos-and-flakes.thiscute.world/best-practices/nix-path-and-flake-registry

  nix = {
    # Remote builds
    distributedBuilds = true;
    # The remote builder:
    settings.trusted-users = ["michal"];
    extraOptions = ''
      builders-use-substitutes = true
    '';
    # The buildee:
    buildMachines = [
      {
        hostName = "nix-fw";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        # if the builder supports building for multiple architectures,
        # replace the previous line by, e.g.
        # systems = ["x86_64-linux" "aarch64-linux"];
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
    ];

    # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
    registry.nixpkgs.flake = inputs.nixpkgs;
    channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.
  };

  # but NIX_PATH is still used by many useful tools, so we set it to the same value as the one used by this flake.
  # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  environment.etc."nix/inputs/nixpkgs".source = "${inputs.nixpkgs}";
  # https://github.com/NixOS/nix/issues/9574
  nix.settings.nix-path = lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";

  # nh CLI

  home-manager.users.${username} = {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 8d --keep 4";
      };
      flake = "~/Documents/nix-config"; # Use this flake by default
    };
  };
}
