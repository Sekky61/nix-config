#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
homelab_dir="$(cd "${script_dir}/.." && pwd)"
quadlet_dir="${HOME}/.config/containers/systemd"
n8n_data_dir="${homelab_dir}/data/n8n"
openclaw_data_dir="${homelab_dir}/data/openclaw"

require_command() {
  local cmd="$1"

  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Error: required command '${cmd}' not found in PATH" >&2
    exit 1
  fi
}

require_command podman
require_command systemctl

enable_or_start_service() {
  local service_name="$1"
  local unit_file_state

  unit_file_state="$(systemctl --user show -p UnitFileState --value "${service_name}.service" 2>/dev/null || true)"

  case "${unit_file_state}" in
    generated|transient|static)
      echo "${service_name}.service has UnitFileState='${unit_file_state}'; skipping enable and starting only"
      ;;
    *)
      systemctl --user enable "${service_name}.service"
      ;;
  esac

  systemctl --user start "${service_name}.service"
}

if ! podman --version >/dev/null 2>&1; then
  echo 'Error: podman is installed but not working correctly' >&2
  exit 1
fi

if ! systemctl --user show-environment >/dev/null 2>&1; then
  echo 'Error: user systemd is not available; run this as a logged-in user session' >&2
  exit 1
fi

mkdir -p "${quadlet_dir}" "${n8n_data_dir}" "${openclaw_data_dir}"

cp "${homelab_dir}/networks/homelab.network" "${quadlet_dir}/homelab.network"

sed "s|__N8N_DATA_DIR__|${n8n_data_dir}|g" \
  "${homelab_dir}/n8n/n8n.container" > "${quadlet_dir}/n8n.container"

sed "s|__OPENCLAW_DATA_DIR__|${openclaw_data_dir}|g" \
  "${homelab_dir}/openclaw/openclaw.container" > "${quadlet_dir}/openclaw.container"

if [[ ! -f "${quadlet_dir}/n8n.env" ]]; then
  cp "${homelab_dir}/n8n/n8n.env.example" "${quadlet_dir}/n8n.env"
  echo "Created ${quadlet_dir}/n8n.env from example"
fi

if [[ ! -f "${quadlet_dir}/openclaw.env" ]]; then
  cp "${homelab_dir}/openclaw/openclaw.env.example" "${quadlet_dir}/openclaw.env"
  echo "Created ${quadlet_dir}/openclaw.env from example"
fi

systemctl --user daemon-reload
# Quadlet-generated network units are generated/transient on some setups,
# so start the network but do not try to enable it directly.
systemctl --user start homelab-network.service

enable_or_start_service n8n
enable_or_start_service openclaw

echo "Installed Quadlets to ${quadlet_dir}"
echo "n8n should be available at http://localhost:5678"
echo "OpenClaw should be available at http://localhost:18789"
