{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.michal.network.cloudflare-warp;
  # TODO added 2026-10-22; estimate: next nixpkgs refresh, likely days to weeks.
  # Remove once locked nixpkgs.cloudflare-warp is at least 2026.8.2115.0.
  version = "2026.8.2115.0";
  package = pkgs.cloudflare-warp.overrideAttrs (_: {
    inherit version;
    src = pkgs.fetchurl {
      name = "cloudflare-warp_${version}_amd64.deb";
      url = "https://downloads.cloudflareclient.com/v1/download/noble-intel/version/${version}";
      hash = "sha256-AgkQeGDDxoUamrj9A2kBIaPeoxmbCE+Bl2IAcsZxzWg=";
    };
  });
in
{
  options.michal.network.cloudflare-warp = {
    enable = mkEnableOption "Cloudflare WARP";
  };

  config = mkIf cfg.enable {
    services.cloudflare-warp = {
      enable = true;
      inherit package;
    };
  };
}
