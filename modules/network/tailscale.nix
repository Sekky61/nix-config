{
  lib,
  config,
  username,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf mkAliasOptionModule mkForce;
  inherit (lib) optional getExe;
  inherit (lib.types) str enum nullOr;
  cfg = config.michal.services.tailscale;
in {
  # Now login as Sekky61@github using
  # sudo tailscale up/login

  # exit node:
  # sudo tailscale up --advertise-exit-node

  # When up, `ssh michal@nix-wsl` should be enough
  # If you need to access a port (like 4200), running the program on host 0.0.0.0 (not localhost!) should just work

  # HTTPS
  # You need to generate certs and renew them. In NixOS, I have not figured it out yet

  options.michal.services.tailscale = {
    enable = mkEnableOption "Tailscale";
    systray.enable = mkEnableOption "systray";
    operator = mkOption {
      type = nullOr str;
      default = null;
      description = "User set as tailscale operator, helps with taildrop stuff";
    };
    exitNode = {
      enable = mkEnableOption "Enable use as exit node";
      networkDevice = mkOption {
        default = "eth0";
        type = str;
        description = ''
          the name of the network device to be used for exitNode Optimization script
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable Tailscale VPN service with routing features for both client and subnet router
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraSetFlags =
        [
          "--webclient"
        ]
        ++ optional cfg.exitNode.enable "--advertise-exit-node"
        ++ optional (cfg.operator != null) "--operator=${cfg.operator}";
    };

    home-manager.users.${username} = {
      services.tailscale-systray.enable = cfg.systray.enable;
    };
  };
}
