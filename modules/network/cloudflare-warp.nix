{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.michal.network.cloudflare-warp;
in {
  options.michal.network.cloudflare-warp = {
    enable = mkEnableOption "Cloudflare WARP";
  };

  config = mkIf cfg.enable {
    services.cloudflare-warp.enable = true;
  };
}
