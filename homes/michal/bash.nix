{
  pkgs,
  config,
  lib,
  ...
}: {
  config = {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = builtins.readFile ./config/.bash_aliases;
      initExtra = builtins.readFile ./config/interactive.sh;
      shellAliases = {
        l = "eza";
        ls = "eza --color=auto";
        la = "eza -a";
        ll = "eza -lah";
        cat = "bat";
        gitlog = "git log --graph --oneline --decorate";
      };
    };
  };
}
