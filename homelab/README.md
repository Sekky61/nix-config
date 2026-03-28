# Homelab (Podman Quadlet)

This directory keeps rootless Podman Quadlet definitions for homelab services.

Inspired by: https://github.com/fpatrick/podman-quadlet

Runtime state under `homelab/data/` and `homelab/docker/` is local-only and ignored by git.

## Quick start

1. Prepare directories and env:
   - `mkdir -p homelab/data/n8n homelab/data/openclaw ~/.config/containers/systemd`
   - `cp homelab/n8n/n8n.env.example ~/.config/containers/systemd/n8n.env`
   - `cp homelab/openclaw/openclaw.env.example ~/.config/containers/systemd/openclaw.env`
2. Install quadlet files:
   - `./homelab/scripts/install-quadlets.sh`
3. Start services:
   - `systemctl --user start n8n.service`
   - `systemctl --user start openclaw.service`
4. Open:
   - `http://localhost:5678`
   - `http://localhost:18789`

## Lifecycle (simple)

Think of it like this:

- Files in `homelab/` are your source of truth (what you edit in git).
- Files in `~/.config/containers/systemd/` are the live copies systemd uses.
- `./homelab/scripts/install-quadlets.sh` copies source files to live copies and reloads systemd.
- Everything stays reproducible (env setup is needed though) thanks to this simple workflow
- Local runtime files under `homelab/data/` are intentionally not part of the repo.

When to run `install-quadlets.sh`:

- Run it the first time you set this up.
- Run it again any time you change `*.container` or `*.network` files in `homelab/`.
- Run it after `git pull` if homelab files changed.

When to restart containers:

- Restart `SERVICE_NAME` after changing `~/.config/containers/systemd/SERVICE_NAME.env`.
- Command example: `systemctl --user restart n8n.service`

How to check if it is working:

- Status: `systemctl --user status n8n.service --no-pager`
- Logs: `journalctl --user -u n8n.service -n 100 --no-pager`
- Open UI: `http://localhost:5678`

Day-to-day update flow:

1. `git pull`
2. `./homelab/scripts/install-quadlets.sh`
3. `systemctl --user restart n8n.service`
4. `systemctl --user restart openclaw.service`
5. `systemctl --user status n8n.service --no-pager`
6. `systemctl --user status openclaw.service --no-pager`

## Persistence (what survives restarts)

Short answer: persistence is the mounted n8n data dir.

- `homelab/data/n8n` is mounted into the container as `/home/node/.n8n`.
- That directory keeps n8n state (including SQLite DB by default), config, and keys.
- If that directory is deleted, n8n starts like a fresh install.
- `~/.config/containers/systemd/n8n.env` is also important persistent config (especially secrets), but it is config, not app data.

Backups:
- Back up `homelab/data/n8n` and `~/.config/containers/systemd/n8n.env`.

## How `~/.config/containers/systemd` works

- For rootless Quadlet, systemd reads unit definitions from `~/.config/containers/systemd` (your user-level config, not repo-managed by default).
- In this repo, `homelab/*.container` and `homelab/*.network` are source files; `./homelab/scripts/install-quadlets.sh` copies rendered files into `~/.config/containers/systemd`.
- Expect `~/.config/containers/systemd/n8n.container`, `~/.config/containers/systemd/openclaw.container`, and `~/.config/containers/systemd/homelab.network` to be overwritten on each install run.
- Expect `~/.config/containers/systemd/n8n.env` and `~/.config/containers/systemd/openclaw.env` to be preserved after first creation (script only creates them if missing).
- After install, script runs `systemctl --user daemon-reload` and starts services so changes are picked up.
- Install keeps the current autostart state by default.
- To change autostart during install, run `./homelab/scripts/install-quadlets.sh --autostart on` or `./homelab/scripts/install-quadlets.sh --autostart off`.
- For day-to-day toggling, use `homelab-autostart on`, `homelab-autostart off`, or `homelab-autostart status`.
- The network unit is started (not enabled) because Quadlet may generate it as transient; this avoids `...is transient or generated` errors.
- On some systems, service units are treated as generated/transient and cannot be enabled; the script falls back to `start` so install still succeeds.

What to sync and how often:

- Sync repo config (`git pull` + rerun install script) whenever you change Quadlet files in `homelab/`, switch branches, or pull homelab updates.
- For normal operation, no periodic sync is required if nothing changed.
- Keep host-specific values and secrets in `~/.config/containers/systemd/n8n.env`; update only when your host/domain/secrets change.
- A practical cadence is event-based (on config changes), plus an optional monthly review to rotate credentials and confirm env values.

## Notes

- This setup is rootless and uses your user systemd instance.
- The install script writes an absolute `Volume=` path to `homelab/data/n8n` in this repo.
- If you want auto-updates, enable the timer:
  - `systemctl --user enable --now podman-auto-update.timer`
