{ username, ... }:
{
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
  };

    programs.gnupg = {
      # ssh passwords
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
}
