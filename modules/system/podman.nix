{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.podman;
in {
  options.michal.programs.podman = {enable = mkEnableOption "Podman";};

  config = mkIf cfg.enable {
    # Podman is the default for running oci containers
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled =
        true; # Required for containers under podman-compose to be able to talk to each other.
    };
    # User permissions
    users.users.${username}.extraGroups = ["podman"];
  };
}
