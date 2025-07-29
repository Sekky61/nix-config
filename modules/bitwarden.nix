{
  config,
  pkgs,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.michal.programs.bitwarden;
  # helper to unlock bw and export session automatically
  jq = "${pkgs.jq}/bin/jq";
  bw = "${pkgs.bitwarden-cli}/bin/bw";
  # this needs to be a shell function due to 'export'
  bwuFunc = ''
    function bwu() {
      BW_STATUS=$(${bw} status | ${jq} -r .status)
      case "$BW_STATUS" in
      "unauthenticated")
          echo "Logging into Bitwarden"
          export BW_SESSION=$(${bw} login --raw)
          ;;
      "locked")
          echo "Unlocking Vault"
          export BW_SESSION=$(${bw} unlock --raw)
          ;;
      "unlocked")
          echo "Vault is unlocked"
          ;;
      *)
          echo "Unknown Login Status: $BW_STATUS"
          return 1
          ;;
      esac
      ${bw} sync
    }
  '';
in {
  options.michal.programs.bitwarden = {
    enable = mkEnableOption "the bitwarden cli client";
  };

  config = mkIf cfg.enable {
    programs.bash.interactiveShellInit = bwuFunc;

    # Usage:
    # - `bwu` - Logs you in/unlocks vault
    # - `bw get password claude.ai`

    home-manager.users.${username} = {
      home.packages = with pkgs; [bitwarden-cli bitwarden-desktop];
    };
  };
}
