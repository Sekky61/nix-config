{
  lib,
  config,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.opencode;
  dev_cfg = config.michal.dev;
in {
  options.michal.programs.opencode = {enable = mkEnableOption "Opencode";};

  config = mkMerge [
    (mkIf dev_cfg.enable {michal.programs.opencode.enable = mkDefault true;})

    (mkIf cfg.enable {
      home-manager.users.${username} = {
        programs.bash.shellAliases.oc = "opencode";
        programs.opencode = {
          enable = true;
          # Plugins:
          # - https://github.com/NoeFabris/opencode-antigravity-auth

          # Package is overwritten in overlay

          # Settings have permissions problems, probably need write?
          # settings = {
          #   # https://opencode.ai/docs/config
          #   instructions = ["{file:./4.1-Beast.chatmode.md}"];
          #   mcp = {
          #     mcp-deepwiki = {
          #       command = ["npx" "-y" "mcp-deepwiki@latest"];
          #       enabled = true;
          #       type = "local";
          #     };
          #     playwright = {
          #       command = [
          #         "npx"
          #         "@playwright/mcp@latest"
          #       ];
          #       enabled = true;
          #       type = "local";
          #     };
          #   };
          # };
        };
      };
    })
  ];
}
