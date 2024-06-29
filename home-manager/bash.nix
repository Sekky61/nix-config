{pkgs, config, lib, ... }:
{
  config = {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = builtins.readFile ../dotfiles/cfg/.bash_aliases;
      initExtra = builtins.readFile ../dotfiles/cfg/interactive.sh;
      shellAliases = {
        l = "eza";
        ls = "exa --color=auto";
        la = "eza -a";
        ll = "eza -lah";
        cat = "bat";

        color_test = "c_test";
        clone = "x-terminal-emulator &";
      };
    };
  };
}