{...}: {
  imports = [
    ./starship.nix
  ];

  # Here defined aliases are available for all users
  programs.bash = {
    completion.enable = true;
    shellInit = builtins.readFile ./.bash_aliases;
    interactiveShellInit = builtins.readFile ./interactive.sh;
    shellAliases = {
      l = "eza";
      ls = "eza --color=auto";
      la = "eza -a";
      ll = "eza -lah";
      cat = "bat";

      gitlog = "git log --graph --oneline --decorate";
      initenvrc = "echo \"use flake\" >> .envrc && direnv allow";
    };
  };
}
