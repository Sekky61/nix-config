{
  username,
  pkgs,
  ...
}: let
  vcsEmail = "misa@majer.cz";
  vcsName = "Sekky61";
in {
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      signing = {
        format = "ssh";
        signByDefault = true;
        key = "~/.ssh/id_ed25519";
      };
      settings = {
        credential.helper = "cache --timeout=3600";
        user = {
          name = vcsName;
          email = vcsEmail;
        };

        # Signing
        commit.gpgsign = true;
        tag.gpgsign = true;

        # More options
        rebase.updateRefs = true;
        merge.conflictstyle = "diff3";
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
    ];

    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
        };
        git = {
          mainBranches = [
            "master"
            "main"
            "develop"
          ];
          parseEmoji = true;
          commitPrefix = [
            {
              # add feat: prefix to commit messages
              pattern = "^[A-Z]+-\\d+-(feat|fix|chore|refactor).*";
              replace = "$1: ";
            }
          ];
        };
        update.method = "never";
        # https://github.com/jesseduffield/lazygit/wiki/Custom-Commands-Compendium
        customCommands = [
          {
            key = "G";
            command = "gh pr view -w {{.SelectedLocalBranch.Name}}";
            context = "localBranches";
            description = "Open Github PR in browser";
          }
          {
            key = "G";
            command = "gh pr view -w";
            context = "commits";
            description = "Open Github PR in browser";
          }
          {
            key = "<c-p>";
            command = "git remote prune {{.SelectedRemote.Name}}";
            context = "remotes";
            loadingText = "Pruning...";
            description = "prune deleted remote branches";
          }
          {
            key = "<c-v>";
            context = "global";
            description = "Quick conventional commit";
            prompts = [
              {
                type = "menu";
                key = "QuickCommit";
                title = "Choose a quick commit";
                options = [
                  {
                    name = "fix: cr feedback";
                    value = "fix: cr feedback";
                  }
                  {
                    name = "fix: apply autofix";
                    value = "fix: apply autofix";
                  }
                  {
                    name = "chore: translations";
                    value = "chore: translations";
                  }
                ];
              }
            ];
            command = "git commit -m '{{.Form.QuickCommit}}'";
            loadingText = "Creating quick commit...";
          }
        ];
      };
    };
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = vcsEmail;
          name = vcsName;
        };
      };
    };
    programs.jjui = {
      # jujutsu tui
      enable = true;
    };
  };

  environment.shellAliases = {
    gitlog = "git log --graph --oneline --decorate";
    # [f]uzzy [c]heckout
    fc = "git branch --sort=-committerdate --format='%(refname:short)' | fzf --header 'git checkout' | xargs git checkout";
    # [f]uzzy [p]pull request
    fp = "gh pr list | fzf --header 'checkout pr' | awk '{print $(NF-5)}' | xargs git checkout";
    lg = "lazygit";
  };
}
