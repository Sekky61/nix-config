{ pkgs, ... }:

{
  users.users.t3code = {
    isSystemUser = true;
    group = "t3code";
    home = "/var/lib/homelab/t3code";
    createHome = true;
  };
  users.groups.t3code = {};

  systemd.services.t3code = {
    description = "T3 Code server";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sops-install-secrets.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "sops-install-secrets.service" ];
    serviceConfig = {
      User = "t3code";
      Group = "t3code";
      WorkingDirectory = "/var/lib/homelab/t3code";
      Environment = "GIT_SSH_COMMAND=/etc/t3code-git-ssh";
      ExecStart = "${pkgs.michal-unstable.t3code}/bin/t3 serve --host 0.0.0.0 --port 3773";
      Restart = "on-failure";
    };
  };

  environment.etc."t3code-git-ssh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      exec ${pkgs.openssh}/bin/ssh -i /run/secrets/git/food-organizer-deploy-key -o IdentitiesOnly=yes "$@"
    '';
  };

  environment.systemPackages = [
    pkgs.gh
    pkgs.michal-unstable.codex
  ];
}
