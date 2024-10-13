{ pkgs
, username
, ...
}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Now login as Sekky61@github using
  # sudo tailscale up

  # exit node:
  # sudo tailscale up --advertise-exit-node


}
