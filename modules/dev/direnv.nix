{username, ...}: {
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
    programs.git = {
      ignores = [
        ".direnv"
      ];
    };
  };
}
