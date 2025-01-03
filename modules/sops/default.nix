{ pkgs, config, ... }:
{
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  # This will add secrets.yml to the nix store
  sops.defaultSopsFile = ./secrets.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # Decryption key
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  # This would include the path
  # key = config.sops.secrets."nixpi/tailscale-api-key".path;
  # This would include the value
  # key = config.sops.placeholder."nixpi/tailscale-api-key";

  # This is the actual specification of the secrets.
  sops.secrets = {
    "nixpi/tailscale-api-key" = { };
    "nixpi/tailscale-id" = { };
    "home/longitude" = { };
    "home/latitude" = { };
  };

  sops.secrets.wireless = {
    neededForUsers = true;
  };

  sops.templates.homepage-env-file.content = ''
    HOMEPAGE_VAR_NIXPI_TAILSCALE_API_KEY=${config.sops.placeholder."nixpi/tailscale-api-key"}
    HOMEPAGE_VAR_NIXPI_TAILSCALE_ID=${config.sops.placeholder."nixpi/tailscale-id"}
  '';
}
