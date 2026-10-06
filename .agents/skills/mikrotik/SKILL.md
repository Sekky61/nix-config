---
name: mikrotik
description: Use when inspecting, diagnosing, or changing the user's MikroTik RouterOS router. Connect through the local SSH alias `mikrotik` and make careful, minimal changes.
---

# MikroTik

- Connect from `nix-fw` with `ssh mikrotik`. Use only credentials and keys already configured locally; never ask for or print private keys, passwords, or tokens.
- If the router address is unknown, discover the current default gateway locally without scanning the LAN:
  ```sh
  mikrotik_gateway_ip() {
    ip -4 route show default |
      awk '$1 == "default" { for (i = 1; i <= NF; i++) if ($i == "via") print $(i + 1) }' |
      sort -u |
      awk 'NR == 1 { ip = $0 } NR == 2 { exit 1 } END { if (NR == 1) print ip; else exit 1 }'
  }
  mikrotik_gateway_ip
  ```
  Treat the result as the router address only when the active network context indicates this gateway is the MikroTik. If there is no single gateway or that is unclear, stop and ask instead of guessing.
- Start with read-only inspection. Before changes, save a RouterOS backup/export, make one narrow change at a time, and verify the result and continued access.
- Use RouterOS Safe Mode for changes that could cut off management access. Carry out narrow changes the user explicitly requests; get approval before destructive or broad changes such as resetting, upgrading, bulk-importing, or replacing WAN, firewall, bridge/VLAN, DHCP, or management-access configuration.
- If the SSH alias or key is missing, explain the local setup steps. Never guess credentials or router addresses.
