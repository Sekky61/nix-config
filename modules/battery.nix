{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.michal.services.battery;
  monitorScriptName = "battery-monitor-service";

  batteryMonitorScript = pkgs.writeShellApplication {
    name = monitorScriptName;

    runtimeInputs = [
      pkgs.jq
      pkgs.libnotify
      pkgs.bc
      pkgs.coreutils
      pkgs.astal.battery
    ];

    text = ''
      WARN_LEVEL=${toString cfg.warnBatteryLevel}
      CRIT_LEVEL=${toString cfg.critBatteryLevel}
      LAST_NOTIFIED=-1

      echo "Starting Battery Monitor..."

      # We add 'stdbuf -oL' (optional) or ensure the pipe is unbuffered so the loop reacts instantly
      astal-battery -m | while read -r line; do

        STATE=$(echo "$line" | jq -r '.state')
        PCT=$(echo "$line" | jq -r '.percentage')

        if [ "$STATE" = "2" ]; then
          # Use printf for safer float-to-int conversion in shell
          CURRENT_INT=$(printf "%.0f" "$(echo "$PCT * 100" | bc)")

          if (( $(echo "$PCT <= $CRIT_LEVEL" | bc -l) )); then
             if [ "$CURRENT_INT" -ne "$LAST_NOTIFIED" ]; then
                notify-send -c device -u critical "Low Battery" "Charge me or watch me die! (''${CURRENT_INT}%)"
                LAST_NOTIFIED=$CURRENT_INT
             fi

          elif (( $(echo "$PCT <= $WARN_LEVEL" | bc -l) )); then
             if [ "$CURRENT_INT" -ne "$LAST_NOTIFIED" ]; then
                notify-send -c device -u normal "Low Battery" "Would be wise to keep my charger nearby. (''${CURRENT_INT}%)"
                LAST_NOTIFIED=$CURRENT_INT
             fi
          fi
        else
          LAST_NOTIFIED=-1
        fi
      done
    '';
  };
in {
  options.michal.services.battery = {
    enable = mkEnableOption "the battery monitoring service";

    enableNotifications = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to send battery level notifications";
    };

    warnBatteryLevel = mkOption {
      type = types.float;
      default = 0.10;
      description = "Battery level (as fraction) at which to show warning notification";
    };

    critBatteryLevel = mkOption {
      type = types.float;
      default = 0.05;
      description = "Battery level (as fraction) at which to show critical notification";
    };
  };

  config = mkIf cfg.enable {
    services.upower.enable = true;

    # Expose it for debug
    environment.systemPackages = [batteryMonitorScript];

    systemd.user.services.battery-monitor = {
      enable = cfg.enableNotifications;
      description = "Astal Battery Monitoring Daemon";

      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];

      serviceConfig = {
        ExecStart = "${batteryMonitorScript}/bin/${monitorScriptName}";
        Restart = "always";
        RestartSec = "5s";
        NoNewPrivileges = true;
      };
    };
  };
}
