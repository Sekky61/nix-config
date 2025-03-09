{lib, ...}: {
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
      user.signingkey = "~/.ssh/id_ed25519.pub";
      diff.algorithm = "histogram";
    };
    ignores = [
      ".direnv"
    ];
  };
}
