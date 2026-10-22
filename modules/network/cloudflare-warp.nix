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
  configureWarpDns = pkgs.writeShellScript "configure-cloudflare-warp-dns" ''
    for attempt in $(${pkgs.coreutils}/bin/seq 1 30); do
      if ${pkgs.systemd}/bin/resolvectl dns CloudflareWARP 127.0.2.2 127.0.2.3 \
        && ${pkgs.systemd}/bin/resolvectl domain CloudflareWARP '~.'; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done

    echo "CloudflareWARP DNS setup did not find the interface after 30 seconds" >&2
    exit 1
  '';
in
{
  options.michal.network.cloudflare-warp = {
    enable = mkEnableOption "Cloudflare WARP";
  };

  config = mkIf cfg.enable {
    # Cloudflare's Linux connectivity check needs systemd-resolved to resolve
    # the single-label internal name `connectivity-check.warp-svc`.
    services.resolved.settings.Resolve.ResolveUnicastSingleLabel = true;

    services.cloudflare-warp = {
      enable = true;
      inherit package;
    };

    # WARP creates its tunnel interface asynchronously. Reapply DNS routing
    # whenever the interface is recreated, so its connectivity check can use
    # the local WARP DNS proxy for `connectivity-check.warp-svc`.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="CloudflareWARP", TAG+="systemd", ENV{SYSTEMD_WANTS}+="cloudflare-warp-dns.service"
    '';

    systemd.services.cloudflare-warp-dns = {
      description = "Route DNS through Cloudflare WARP";
      after = [ "systemd-resolved.service" "cloudflare-warp.service" ];
      wants = [ "cloudflare-warp.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = configureWarpDns;
      };
    };
  };
}
