{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.michal.programs.aikido-endpoint-protection;
  package = pkgs.aikido-endpoint-protection;
  tokenFile = config.sops.secrets.aikido_endpoint_protection_token.path;
  stateDir = "/var/lib/aikidosecurity/endpoint-protection";
  configFile = "${stateDir}/run/config.json";
  packageDir = "${package}/opt/aikidosecurity/endpoint-protection";
  proxyCaFile = "${stateDir}/run/endpoint-protection-proxy-ca-crt.pem";
  caBundleFile = "${stateDir}/run/ca-bundle.pem";
  # Zen's browser-specific CA import policy is configured in ./gui-packages/browser/zen.nix.

  refreshCaBundle = pkgs.writeShellScript "aikido-endpoint-protection-refresh-ca-bundle" ''
    set -eu
    ${pkgs.coreutils}/bin/install -d -m 0755 ${escapeShellArg "${stateDir}/run"}
    umask 022
    bundle=${escapeShellArg caBundleFile}
    ${pkgs.coreutils}/bin/cat /etc/ssl/certs/ca-certificates.crt > "$bundle.tmp"
    if [ -s ${escapeShellArg proxyCaFile} ]; then
      printf '\n' >> "$bundle.tmp"
      ${pkgs.coreutils}/bin/cat ${escapeShellArg proxyCaFile} >> "$bundle.tmp"
    fi
    ${pkgs.coreutils}/bin/chmod 0644 "$bundle.tmp"
    ${pkgs.coreutils}/bin/mv "$bundle.tmp" "$bundle"
  '';

  tokenAvailable = pkgs.writeShellScript "aikido-endpoint-protection-token-available" ''
    if [ -s ${escapeShellArg configFile} ]; then
      exit 0
    fi

    ${pkgs.gnugrep}/bin/grep -q '[^[:space:]]' ${escapeShellArg tokenFile}
  '';

  initializeConfig = pkgs.writeShellScript "aikido-endpoint-protection-initialize-config" ''
    config=${escapeShellArg configFile}
    if [ -e "$config" ]; then
      ${pkgs.jq}/bin/jq '.disable_ui = true' "$config" > "$config.tmp"
      ${pkgs.coreutils}/bin/chmod 0600 "$config.tmp"
      ${pkgs.coreutils}/bin/mv "$config.tmp" "$config"
      exit 0
    fi

    ${pkgs.coreutils}/bin/install -d -m 0755 ${escapeShellArg "${stateDir}/run"}
    umask 077
    ${pkgs.jq}/bin/jq -n --rawfile token ${escapeShellArg tokenFile} \
      '{token: ($token | gsub("[\\r\\n]"; "")), disable_ui: true, ephemeral_secrets: false, proxy_mode: "l4"}' \
      > "$config.tmp"
    ${pkgs.coreutils}/bin/mv "$config.tmp" "$config"
    ${pkgs.coreutils}/bin/chmod 0600 "$config"
  '';
in {
  options.michal.programs.aikido-endpoint-protection = {
    enable = mkEnableOption "Aikido Device Protection endpoint agent";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [package];

    sops.secrets.aikido_endpoint_protection_token = {
      mode = "0400";
    };

    nix.settings.ssl-cert-file = caBundleFile;
    environment.variables = {
      CURL_CA_BUNDLE = caBundleFile;
      GIT_SSL_CAINFO = caBundleFile;
      NIX_SSL_CERT_FILE = caBundleFile;
      SSL_CERT_FILE = caBundleFile;
    };

    systemd.services.aikido-endpoint-protection-ca-bundle = {
      description = "Prepare system CA bundle for Aikido Device Protection";
      wantedBy = ["multi-user.target"];
      before = ["aikido-endpoint-protection.service" "nix-daemon.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = refreshCaBundle;
      };
    };

    systemd.services.nix-daemon = {
      wants = ["aikido-endpoint-protection-ca-bundle.service"];
      after = ["aikido-endpoint-protection-ca-bundle.service"];
    };

    systemd.services.aikido-endpoint-protection = {
      description = "Aikido Endpoint Protection";
      after = ["network-online.target" "sops-nix.service" "aikido-endpoint-protection-ca-bundle.service"];
      wants = ["network-online.target" "sops-nix.service" "aikido-endpoint-protection-ca-bundle.service"];
      wantedBy = ["multi-user.target"];

      unitConfig = {
        StartLimitIntervalSec = 60;
        StartLimitBurst = 10;
      };

      serviceConfig = {
        Type = "simple";
        ExecCondition = tokenAvailable;
        ExecStartPre = [initializeConfig refreshCaBundle];
        ExecStart = "/opt/aikidosecurity/endpoint-protection/bin/endpoint-protection";
        Environment = [
          "CURL_CA_BUNDLE=${caBundleFile}"
          "GIT_SSL_CAINFO=${caBundleFile}"
          "NIX_SSL_CERT_FILE=${caBundleFile}"
          "SSL_CERT_FILE=${caBundleFile}"
        ];
        User = "root";
        Group = "root";
        AmbientCapabilities = ["CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW"];
        Delegate = true;
        WorkingDirectory = stateDir;
        StandardOutput = "append:/var/log/aikidosecurity/endpoint-protection/endpoint-protection.log";
        StandardError = "append:/var/log/aikidosecurity/endpoint-protection/endpoint-protection.err";
        Restart = "always";
        RestartSec = 5;
        ProtectHome = false;
        NoNewPrivileges = false;
        PrivateTmp = false;
        KillMode = "mixed";
        TimeoutStopSec = 30;
      };
    };

    systemd.services.aikido-endpoint-protection-refresh-ca = {
      description = "Restart Aikido after its proxy CA changes";
      after = ["aikido-endpoint-protection.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "aikido-endpoint-protection-restart-after-ca-change" ''
          ${refreshCaBundle}
          ${pkgs.systemd}/bin/systemctl try-restart aikido-endpoint-protection.service
          ${pkgs.systemd}/bin/systemctl try-restart nix-daemon.service
        '';
      };
    };

    systemd.paths.aikido-endpoint-protection-proxy-ca = {
      description = "Watch for Aikido proxy CA changes";
      wantedBy = ["multi-user.target"];
      before = ["aikido-endpoint-protection.service"];
      pathConfig = {
        PathChanged = proxyCaFile;
        Unit = "aikido-endpoint-protection-refresh-ca.service";
      };
    };

    systemd.tmpfiles.rules = [
      "d /opt/aikidosecurity 0755 root root -"
      "L+ /opt/aikidosecurity/endpoint-protection - - - - ${packageDir}"
      "L+ /etc/ssl/certs/aikido-endpoint-protection-proxy-ca.pem - - - - ${proxyCaFile}"
      "d /var/lib/aikidosecurity 0755 root root -"
      "d ${stateDir} 0755 root root -"
      "d /var/log/aikidosecurity 0755 root root -"
      "d /var/log/aikidosecurity/endpoint-protection 0755 root root -"
    ];
  };
}
