{ username, ... }:
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

    knownHosts = {
      nixpi-wifi = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBimO7J9WOplF/P1YLgWfx5IFy9nGY+sBfn7xoAdY5hZ root@nixpi";
        extraHostNames = [ "nixpi" ];
      };
    };
  };

  programs.gnupg = {
    # ssh passwords
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
