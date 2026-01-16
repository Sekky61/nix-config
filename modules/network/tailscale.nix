{
  pkgs,
  username,
  ...
}: {
  # Enable Tailscale VPN service with routing features for both client and subnet router
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  home-manager.users.${username} = {
    services.tailscale-systray.enable = true;
  };

  # Now login as Sekky61@github using
  # sudo tailscale up/login

  # exit node:
  # sudo tailscale up --advertise-exit-node

  # When up, `ssh michal@nix-wsl` should be enough
  # If you need to access a port (like 4200), running the program on host 0.0.0.0 (not localhost!) should just work

  # HTTPS
  # You need to generate certs and renew them. In NixOS, I have not figured it out yet
}
