{
  inputs,
  pkgs,
  config,
  username,
  ...
}: {
  # Great article: https://unmovedcentre.com/posts/secrets-management

  imports = [
    inputs.sops-nix.nixosModules.sops # important to include "inputs"
  ];

  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;

    age = {
      # Age is derived from this ssh key
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      # Decryption key
      keyFile = "/var/lib/sops-nix/key.txt";
      # This will generate a new key if the key specified above does not exist
      generateKey = true;
    };

    # This is the actual specification of the secrets.
    secrets = {
      "home/longitude" = {};
      "home/latitude" = {};
      "atuin_key" = {};
      "personal_email" = {
        owner = config.users.users.${username}.name;
      };

      "private_keys/id_ed25519" = {
        path = "${config.users.users.${username}.home}/.ssh/id_ed25519";
        owner = config.users.users.${username}.name;
      };

      # Passwordless key for disk backup
      "borg-backup/key" = {};
      "borg-backup/passphrase" = {};
    };
  };

  # On new host, generate key with `ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`.
  # Optionally prefix with `nix-shell -p `.
}
