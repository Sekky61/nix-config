{
  lib,
  pkgs,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.claude-code;
  dev_cfg = config.michal.dev;
in {
  options.michal.programs.claude-code = {
    enable = mkEnableOption "Claude Code";
  };

  config = mkMerge [
    (mkIf dev_cfg.enable {
      michal.programs.claude-code.enable = mkDefault true;
    })

    (mkIf cfg.enable {
      home-manager.users.${username} = {
        programs.bash.shellAliases.cc = "claude";
        programs.claude-code = {
          enable = true;
          settings = {
            effortLevel = "high";
            defaultMode = "auto";
            env = {
              CLAUDE_CODE_NO_FLICKER = 1;
              CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION = "false";
            };
            sandbox = {
              enabled = false;
            };
            enabledPlugins = {
              "eos-jira@eos-clubzone" = true;
              "eos-support-tools@eos-clubzone" = true;
              "eos-docs-search@eos-clubzone" = true;
              "eos-dev-workflow@eos-clubzone" = true;
            };
            permissions = {
              allow = [
                "Bash(grep:*)"
                "Bash(find:*)"
                "Bash(ls:*)"
                "Bash(cat:*)"
                "Bash(head:*)"
                "Bash(tail:*)"
                "Bash(echo:*)"
                "Bash(pwd)"
                "Bash(which:*)"
                "Bash(git status)"
                "Bash(git status:*)"
                "Bash(git add:*)"
                "Bash(git log:*)"
                "Bash(git diff:*)"
              ];
            };
          };
        };
      };
    })
  ];
}
