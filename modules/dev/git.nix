{
  lib,
  config,
  username,
  pkgs,
  ...
}: let
  vcsEmail = "misa@majer.cz";
  vcsName = "Sekky61";
  cfg = config.michal.dev;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs = {
        git = {
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
        gh = {
          enable = true;
        };
        gh-dash = {
          enable = true;
          settings = {
            prSections = [
              {
                title = "My Pull Requests";
                filters = "is:open author:@me";
                layout.author.hidden = true;
              }
              {
                title = "Needs My Review";
                filters = "is:open label:action:review  -author:@me";
              }
              {
                title = "Involved";
                filters = "is:open involves:@me -author:@me";
              }
            ];
          };
        };
      };

      home.packages = with pkgs; [
        git
        worktrunk
      ];

      programs.lazygit = {
        enable = true;
        settings = {
          gui = {nerdFontsVersion = "3";};
          git = {
            mainBranches = ["master" "main" "develop"];
            parseEmoji = true;
            pagers = [
              {
                pager = ''
                  delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
                '';
                colorArg = "always";
              }
            ];
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

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        enableJujutsuIntegration = true;
      };

      # JJ

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

    # Worktrunk shell integration (enables wt switch to change directory)
    programs.bash.interactiveShellInit = ''
      if command -v wt &>/dev/null; then
        eval "$(wt config shell init bash 2>/dev/null)"
      fi
    '';
  };
}
