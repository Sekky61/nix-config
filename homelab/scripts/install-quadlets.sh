#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
homelab_dir="$(cd "${script_dir}/.." && pwd)"
quadlet_dir="${HOME}/.config/containers/systemd"
data_dir="${homelab_dir}/data/n8n"

require_command() {
  local cmd="$1"

  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Error: required command '${cmd}' not found in PATH" >&2
    exit 1
  fi
}

require_command podman
require_command systemctl

if ! podman --version >/dev/null 2>&1; then
  echo 'Error: podman is installed but not working correctly' >&2
  exit 1
fi

if ! systemctl --user show-environment >/dev/null 2>&1; then
  echo 'Error: user systemd is not available; run this as a logged-in user session' >&2
  exit 1
fi

mkdir -p "${quadlet_dir}" "${data_dir}"

cp "${homelab_dir}/networks/homelab.network" "${quadlet_dir}/homelab.network"

sed "s|__N8N_DATA_DIR__|${data_dir}|g" \
  "${homelab_dir}/n8n/n8n.container" > "${quadlet_dir}/n8n.container"

if [[ ! -f "${quadlet_dir}/n8n.env" ]]; then
  cp "${homelab_dir}/n8n/n8n.env.example" "${quadlet_dir}/n8n.env"
  echo "Created ${quadlet_dir}/n8n.env from example"
fi

systemctl --user daemon-reload
# Quadlet-generated network units are generated/transient on some setups,
# so start the network but do not try to enable it directly.
systemctl --user start homelab-network.service

unit_file_state="$(systemctl --user show -p UnitFileState --value n8n.service 2>/dev/null || true)"

case "${unit_file_state}" in
  generated|transient|static)
    echo "n8n.service has UnitFileState='${unit_file_state}'; skipping enable and starting only"
    ;;
  *)
    systemctl --user enable n8n.service
    ;;
esac

systemctl --user start n8n.service

echo "Installed Quadlets to ${quadlet_dir}"
echo "n8n should be available at http://localhost:5678"
