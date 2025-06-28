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
          main = {
            terminal = "${defaultTerminal} -e";
            prompt = ">>  ";
            layer = "overlay";
            match-counter = true;
            lines = 16;
            width = 50;
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
            radius = 12;
            width = 2;
          };

          dmenu = {
            exit-immediately-if-empty = true;
          };
        };
      };
    };
  };
}
