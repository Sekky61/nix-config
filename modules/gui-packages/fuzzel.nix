{
  config,
  username,
  lib,
  ...
}: let
  defaultTerminal = config.michal.environment.terminal;
  cfg = config.michal.graphical;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.fuzzel = {
        enable = true;
        settings = {
          # https://man.archlinux.org/man/fuzzel.ini.5.en#SECTION:_dmenu
          main = {
            terminal = "${defaultTerminal} -e";
            prompt = "' ➜  '";
            layer = "overlay";
            match-counter = true;
            lines = 25;
            width = 60;
          };

          # Colors can be set by stylix but there is a HM issue
          colors = {
            background = "130F0Dff";
            text = "ece0daff";
            selection = "52443bff";
            selection-text = "d7c3b8ff";
            border = "52443bff";
            match = "ffb783ff";
            selection-match = "ffb783ff";
          };

          border = {
            radius = 20;
            width = 3;
          };

          dmenu = {
            exit-immediately-if-empty = true;
          };
        };
      };
    };
  };
}
