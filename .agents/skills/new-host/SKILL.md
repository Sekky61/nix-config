---
name: New NixOS host
description: Add a new host to this nix config repo
---

Use this skill when adding a new machine/host to this repo.

Steps
1) Create `hosts/<hostname>/` and add:
   - `default.nix` with imports for `./hardware-configuration.nix`, `./configuration.nix`, and any host-only modules (copy a similar host as a template).
   - `configuration.nix` for system settings, users, services, and michal modules.
   - `hardware-configuration.nix` generated on the target via `nixos-generate-config` (or copied from `/etc/nixos/hardware-configuration.nix`).
2) Register the host in `hosts/default.nix` under `hosts`:
   - `specialArgs = { username = "..."; hostname = "..."; inherit inputs self lib; }` (match existing patterns).
   - Add `system = "aarch64-linux";` only if the host is non-x86 and not already set in hardware config.
3) If the host needs deploy-rs, add a `deploy.nodes.<hostname>` entry in `flake.nix` mirroring existing nodes.
4) Ensure `system.stateVersion` is set and `networking.hostName = hostname` remains via `hosts/common/default.nix`.

Notes
- Keep Nix files 2-space indented.
- Prefer copying the closest existing host and adjust settings.
