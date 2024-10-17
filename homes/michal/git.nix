{ lib, ... }:
let
  lang = icon: color: {
    symbol = icon;
    format = "[$symbol ](${color})";
  };
  os = icon: fg: "[${icon} ](fg:${fg})";
  pad = {
    left = "";
    right = "";
  };
in
{
  programs.git = {
    enable = true;
    userName = "Sekky61";
    userEmail = "misa@majer.cz";
    extraConfig = {
      credential.helper = "cache --timeout=3600";
      # Sign all commits using ssh key
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      user.signingkey = "~/.ssh/id_rsa.pub";
    };
    ignores = [
      ".direnv"
      ];
  };
}
