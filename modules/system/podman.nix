{
  pkgs,
  username,
  ...
}: {
  # Podman is the default for running oci containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
  };
  # User permissions
  users.users.${username}.extraGroups = ["podman"];
}
