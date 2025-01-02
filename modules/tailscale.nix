{
  pkgs,
  username,
  ...
}:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  services.resolved.enable = true; # Possible fix for no connection when tailscale is on

  # Now login as Sekky61@github using
  # sudo tailscale up

  # exit node:
  # sudo tailscale up --advertise-exit-node

}
