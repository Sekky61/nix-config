{ pkgs, ... }:

let
  additionalJDKs = with pkgs; [ jdk ];
in
{
  # ...
  programs.java = {
    enable = true;
  };

  home.sessionPath = [ "$HOME/.jdks" ];
  home.file = (builtins.listToAttrs (builtins.map (jdk: {
    name = ".jdks/${jdk.version}";
    value = { source = jdk; };
  }) additionalJDKs));
}
