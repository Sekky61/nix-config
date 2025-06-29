{
  username,
  pkgs,
  ...
}: {
  home-manager.users.${username} = {
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

    home.packages = with pkgs; [
      git
      gh
      lazygit
    ];
  };

  environment.shellAliases = {
    gitlog = "git log --graph --oneline --decorate";
    # [f]uzzy [c]heckout
    fc = "git branch --sort=-committerdate --format='%(refname:short)' | fzf --header 'git checkout' | xargs git checkout";
    # [f]uzzy [p]pull request
    fp = "gh pr list | fzf --header 'checkout pr' | awk '{print $(NF-5)}' | xargs git checkout";
  };
}
