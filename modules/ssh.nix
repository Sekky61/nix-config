{ username, pkgs, ... }:
{
  # different from home-manager.users
  users.users.${username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkCgOhmEum22iwht2rfJxWnbNCVbd0gWOPXdYHO1vPU majer"
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = true;

    # knownHosts = {
    #   nixpi = {
    #     publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBimO7J9WOplF/P1YLgWfx5IFy9nGY+sBfn7xoAdY5hZ root@nixpi";
    #     extraHostNames = [ "nixpi-wifi" ];
    #   };
    # };
  };

  # Keychain section

  environment.systemPackages = with pkgs; [
    gnome-keyring
  ];

  services.gnome.gnome-keyring.enable = true;
}
