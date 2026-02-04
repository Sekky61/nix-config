{
  lib,
  config,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.docker;
in {
  options.michal.programs.docker = {enable = mkEnableOption "Docker";};

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [docker-compose];

    # Docker can also be run rootless
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };
    # User permissions
    users.users.${username}.extraGroups = ["docker"];
  };
}
