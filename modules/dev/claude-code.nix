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
    sound_file=${../../assets/sounds/sheep.mp3}
    notify-send 'CC'
    if [[ -f "$sound_file" ]]; then
      paplay "$sound_file"
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
