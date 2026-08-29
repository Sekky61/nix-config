{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.hunk;
in {
  options.michal.programs.hunk = {
    enable = mkEnableOption "Hunk";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      imports = [inputs.hunk.homeManagerModules.default];

      programs.hunk = {
        enable = true;
        package = inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.hunk;
        settings = {
          theme = "catppuccin-macchiato";
          mode = "auto";
          watch = true;
          line_numbers = true;
          exclude_untracked = false;
          tab_width = 4;
          file_gap = 1;
          hunk_gap = 0;
          wrap_lines = true;
          menu_bar = true;
          agent_notes = true;
          prompt_save_view_preferences = false;
          transparent_background = false;
        };
        enableClaudeIntegration = true;
      };
    };
  };
}
