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

  cc-notification-script = pkgs.writeShellScriptBin "cc-notification-script" ''
    notify-send 'CC'
    sound_files=(
      ${../../assets/sounds/wiwiwi.mp3}
      ${../../assets/sounds/co_robim4.mp3}
    )

    available_sound_files=()
    for sound_file in "''${sound_files[@]}"; do
      if [[ -f "$sound_file" ]]; then
        available_sound_files+=("$sound_file")
      fi
    done

    if (( ''${#available_sound_files[@]} > 0 )); then
      sound_file="''${available_sound_files[RANDOM % ''${#available_sound_files[@]}]}"
      nohup paplay "$sound_file" >/dev/null 2>&1 &
    fi
  '';
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
            sandbox = {
              enabled = false;
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
            hooks = let
              notify-hook = [
                {
                  matcher = "";
                  hooks = [
                    {
                      command = "${cc-notification-script}/bin/cc-notification-script";
                      type = "command";
                    }
                  ];
                }
              ];
            in {
              Stop = notify-hook;
              # Does not run on ordinary stop (or does but is delayed)
              Notification = notify-hook;
            };
          };
        };
      };
    })
  ];
}
