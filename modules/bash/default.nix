{...}: {
  imports = [
    ./starship.nix
    ./scripts.nix
  ];

  environment.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  # Here defined aliases are available for all users
  programs.bash = {
    completion.enable = true;
    blesh.enable = true; # line editor, autocompletions. Alternative: carapace
    interactiveShellInit = builtins.readFile ./interactive.sh;
  };
}
