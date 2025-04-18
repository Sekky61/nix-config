{...}: {
  imports = [
    ./starship.nix
    ./scripts.nix
  ];

  # todo move
  environment.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    gitlog = "git log --graph --oneline --decorate";
    initenvrc = "echo \"use flake\" >> .envrc && direnv allow";
    # [f]uzzy [c]heckout
    fc = "git branch --sort=-committerdate --format='%(refname:short)' | fzf --header 'git checkout' | xargs git checkout";
    # [f]uzzy [p]pull request
    fp = "gh pr list | fzf --header 'checkout pr' | awk '{print $(NF-5)}' | xargs git checkout";
  };

  # Here defined aliases are available for all users
  programs.bash = {
    completion.enable = true;
    blesh.enable = true; # line editor, autocompletions. Alternative: carapace
    interactiveShellInit = builtins.readFile ./interactive.sh;
  };
}
