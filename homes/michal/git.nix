{
  programs.git = {
    enable = true;
    userName = "Sekky61";
    userEmail = "misa@majer.cz";
    extraConfig = {
      credential.helper = "cache --timeout=3600";

      # Signing
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      user.signingkey = "~/.ssh/id_ed25519.pub";

      # More options
      rebase.updateRefs = true;
      merge.conflictstyle = "zdiff3";
      diff.algorithm = "histogram"; # Verify with `git config --get diff.algorithm`
      rerere = {
        # reuse recorded resolution
        autoupdate = true;
        enabled = true;
      };
    };
  };
}
