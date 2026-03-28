#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
homelab_dir="$(cd "${script_dir}/.." && pwd)"
quadlet_dir="${HOME}/.config/containers/systemd"
n8n_data_dir="${homelab_dir}/data/n8n"
openclaw_data_dir="${homelab_dir}/data/openclaw"
autostart_mode="${HOMELAB_AUTOSTART_SERVICES:-keep}"

log() {
  local message="$1"
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "${message}"
}

usage() {
  cat <<'EOF'
Usage: install-quadlets.sh [--autostart on|off|keep] [-h|--help]

Options:
  --autostart on     Enable homelab service autostart
  --autostart off    Disable homelab service autostart
  --autostart keep   Leave current autostart state unchanged (default)
  -h, --help         Show this help and exit

Environment:
  HOMELAB_AUTOSTART_SERVICES=on|off|keep
  HOMELAB_AUTOSTART_SERVICES=true|false
EOF
}

normalize_autostart_mode() {
  local value="$1"

  case "${value}" in
    true|on|enable|enabled)
      printf 'on\n'
      ;;
    false|off|disable|disabled)
      printf 'off\n'
      ;;
    keep|"")
      printf 'keep\n'
      ;;
    *)
      echo "Error: invalid autostart mode '${value}'" >&2
      usage >&2
      exit 1
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --autostart)
      [[ $# -ge 2 ]] || {
        echo "Error: --autostart requires a value" >&2
        usage >&2
        exit 1
      }
      autostart_mode="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument '$1'" >&2
      usage >&2
      exit 1
      ;;
  esac
done

autostart_mode="$(normalize_autostart_mode "${autostart_mode}")"

require_command() {
  local cmd="$1"

  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Error: required command '${cmd}' not found in PATH" >&2
    exit 1
  fi
}

require_command podman
require_command systemctl

require_file() {
  local file_path="$1"

  if [[ ! -f "${file_path}" ]]; then
    echo "Error: required file '${file_path}' not found" >&2
    exit 1
  fi
}

install_env_example_if_missing() {
  local source_file="$1"
  local destination_file="$2"

  require_file "${source_file}"

  if [[ ! -f "${destination_file}" ]]; then
    cp "${source_file}" "${destination_file}"
    log "Created ${destination_file} from example"
  fi
}

configure_and_start_service() {
  local service_name="$1"
  local unit_file_state
  local active_state
  local sub_state
  local waited_seconds=0
  local wait_timeout_seconds=900

  unit_file_state="$(systemctl --user show -p UnitFileState --value "${service_name}.service" 2>/dev/null || true)"

  case "${autostart_mode}" in
    on)
      case "${unit_file_state}" in
        generated|transient|static)
          log "${service_name}.service has UnitFileState='${unit_file_state}'; skipping enable"
          ;;
        *)
          log "Enabling ${service_name}.service"
          systemctl --user enable "${service_name}.service"
          ;;
      esac
      ;;
    off)
      case "${unit_file_state}" in
        enabled|enabled-runtime|linked|linked-runtime|alias)
          log "Disabling ${service_name}.service autostart"
          systemctl --user disable "${service_name}.service"
          ;;
        generated|transient|static)
          log "${service_name}.service has UnitFileState='${unit_file_state}'; skipping disable"
          ;;
        *)
          log "${service_name}.service autostart already disabled (${unit_file_state:-unknown})"
          ;;
      esac
      ;;
    keep)
      log "Leaving ${service_name}.service autostart unchanged (${unit_file_state:-unknown})"
      ;;
  esac

  log "Starting ${service_name}.service (first start may take longer while image is pulled)"
  systemctl --user start --no-block "${service_name}.service"

  while true; do
    active_state="$(systemctl --user show -p ActiveState --value "${service_name}.service" 2>/dev/null || true)"
    sub_state="$(systemctl --user show -p SubState --value "${service_name}.service" 2>/dev/null || true)"

    case "${active_state}" in
      active)
        log "${service_name}.service is active (${sub_state})"
        break
        ;;
      failed)
        log "${service_name}.service failed (${sub_state})"
        journalctl --user -u "${service_name}.service" -n 60 --no-pager || true
        return 1
        ;;
      *)
        if (( waited_seconds % 10 == 0 )); then
          log "Waiting for ${service_name}.service: ${active_state}/${sub_state}"
        fi
        ;;
    esac

    if (( waited_seconds >= wait_timeout_seconds )); then
      log "Timed out waiting for ${service_name}.service after ${wait_timeout_seconds}s"
      return 1
    fi

    sleep 2
    waited_seconds=$((waited_seconds + 2))
  done
}

if ! podman --version >/dev/null 2>&1; then
  echo 'Error: podman is installed but not working correctly' >&2
  exit 1
fi

if ! systemctl --user show-environment >/dev/null 2>&1; then
  echo 'Error: user systemd is not available; run this as a logged-in user session' >&2
  exit 1
fi

log "Service autostart mode: ${autostart_mode}"

log "Preparing directories"
mkdir -p "${quadlet_dir}" "${n8n_data_dir}" "${openclaw_data_dir}"

require_file "${homelab_dir}/networks/homelab.network"
require_file "${homelab_dir}/n8n/n8n.container"
require_file "${homelab_dir}/openclaw/openclaw.container"

log "Installing network quadlet"
cp "${homelab_dir}/networks/homelab.network" "${quadlet_dir}/homelab.network"

log "Rendering n8n quadlet"
sed "s|__N8N_DATA_DIR__|${n8n_data_dir}|g" \
  "${homelab_dir}/n8n/n8n.container" > "${quadlet_dir}/n8n.container"

log "Rendering OpenClaw quadlet"
sed "s|__OPENCLAW_DATA_DIR__|${openclaw_data_dir}|g" \
  "${homelab_dir}/openclaw/openclaw.container" > "${quadlet_dir}/openclaw.container"

install_env_example_if_missing "${homelab_dir}/n8n/n8n.env.example" "${quadlet_dir}/n8n.env"
install_env_example_if_missing "${homelab_dir}/openclaw/openclaw.env.example" "${quadlet_dir}/openclaw.env"

log "Reloading user systemd daemon"
systemctl --user daemon-reload
# Quadlet-generated network units are generated/transient on some setups,
# so start the network but do not try to enable it directly.
log "Starting homelab-network.service"
systemctl --user start homelab-network.service

configure_and_start_service n8n
configure_and_start_service openclaw

log "Installed Quadlets to ${quadlet_dir}"
log "n8n should be available at http://localhost:5678"
log "OpenClaw should be available at http://localhost:18789"
