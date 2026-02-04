{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.dev;
in {
  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs = {
        # load flake development shell on cd
        direnv = {
          enable = true;
          enableBashIntegration = true;
          nix-direnv.enable = true;
        };
      };

      # Ignore the .envrc file in a git repo
      programs.git = {ignores = [".direnv"];};
    };

    environment.shellAliases = {
      # Run `initenvrc` script to init direnv for flake usage
      initenvrc = ''echo "use flake" >> .envrc && direnv allow'';
    };
  };
}
