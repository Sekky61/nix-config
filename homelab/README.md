# Homelab (Podman Quadlet)

This directory keeps rootless Podman Quadlet definitions for homelab services.

Inspired by: https://github.com/fpatrick/podman-quadlet

Runtime state under `homelab/data/` and `homelab/docker/` is local-only and ignored by git.

## Workflow

Think of the setup in four layers:

- Files in `homelab/` are the source of truth you edit in git.
- Files in `~/.config/containers/systemd/` are the live Quadlets and env files used by user systemd.
- `homelab apply` syncs repo state into the live Quadlet directory.
- `homelab status` shows whether services are configured and healthy.

## Quick start

1. Install CLI deps once:
   - `cd homelab/cli && bun install`
2. Inspect what exists:
   - `bun run start list`
   - `bun run start status`
3. Initialize env if needed:
   - `bun run start env init n8n`
4. Reconcile live Quadlets and start services:
   - `bun run start apply`
5. Open the service:
   - `bun run start open n8n`

Once the CLI is wired into your shell or PATH, use `homelab ...` directly instead of `bun run start ...`.

## Day-to-day commands

- Show discovered resources: `homelab list`
- Show health: `homelab status` or `homelab status n8n`
- Sync repo changes into live Quadlets: `homelab apply`
- Sync one service: `homelab apply n8n`
- Create a local backup archive: `homelab backup` or `homelab backup n8n`
- Initialize env from example: `homelab env init n8n`
- Edit env in your editor: `homelab env edit n8n`
- Restart a service: `homelab service restart n8n`
- Enable autostart: `homelab service enable n8n`
- Disable autostart: `homelab service disable n8n`
- Open the UI: `homelab open n8n`

## When to run what

- After changing `*.container` or `*.network` files, run `homelab apply`.
- After `git pull`, run `homelab status` and then `homelab apply` if homelab files changed.
- After changing `~/.config/containers/systemd/<service>.env`, restart that service with `homelab service restart <service>`.
- Use `homelab status` as the first check before dropping to raw `systemctl` or `journalctl`.

## Persistence

Short answer: persistence is the mounted service data dir plus the live env file.

- `homelab/data/n8n` is mounted into the container as `/home/node/.n8n`.
- That directory keeps n8n state, config, and keys.
- If that directory is deleted, n8n starts like a fresh install.
- `~/.config/containers/systemd/n8n.env` is persistent config, especially secrets, but not app data.

Back up `homelab/data/n8n` and `~/.config/containers/systemd/n8n.env`.

- `homelab backup` creates a tar.gz archive under `homelab/backups/` with service data dirs and live env files.

## How live Quadlets work

- Rootless Quadlet reads units from `~/.config/containers/systemd`.
- `homelab apply` writes live `.container` and `.network` files there.
- `homelab apply` creates missing data dirs under `homelab/data/<service>`.
- `homelab env init <service>` creates the live env file only if it is missing.
- `homelab apply` reloads user systemd and starts the shared network unit.
- Service autostart is managed with `homelab service enable <service>` and `homelab service disable <service>`.

## Notes

- This setup is rootless and uses your user systemd instance.
- The checked-in `homelab/n8n/n8n.env.example` assumes n8n is exposed as a Tailscale service at `n8n.rhino-mora.ts.net`.
- The rendered `Volume=` path points at the local repo path under `homelab/data/<service>`.
- If you want container auto-updates, enable the timer with `systemctl --user enable --now podman-auto-update.timer`.
