# Homelab (Podman Quadlet)

This directory keeps rootless Podman Quadlet definitions for homelab services.

Inspired by: https://github.com/fpatrick/podman-quadlet

## Lifecycle (simple)

Think of it like this:

- Files in `homelab/` are your source of truth (what you edit in git).
- Files in `~/.config/containers/systemd/` are the live copies systemd uses.
- `./homelab/scripts/install-quadlets.sh` copies source files to live copies and reloads systemd.

When to run `install-quadlets.sh`:

- Run it the first time you set this up.
- Run it again any time you change `*.container` or `*.network` files in `homelab/`.
- Run it after `git pull` if homelab files changed.

When to restart containers:

- Restart `n8n` after changing `~/.config/containers/systemd/n8n.env`.
- Restart `openclaw` after changing `~/.config/containers/systemd/openclaw.env`.
- Restart after running install script (safe habit, even if it already started).
- Command: `systemctl --user restart n8n.service`
- Command: `systemctl --user restart openclaw.service`

How to check if it is working:

- Status: `systemctl --user status n8n.service --no-pager`
- Logs: `journalctl --user -u n8n.service -n 100 --no-pager`
- Open UI: `http://localhost:5678`
- Status: `systemctl --user status openclaw.service --no-pager`
- Logs: `journalctl --user -u openclaw.service -n 100 --no-pager`
- Open UI: `http://localhost:18789`

Day-to-day update flow:

1. `git pull`
2. `./homelab/scripts/install-quadlets.sh`
3. `systemctl --user restart n8n.service`
4. `systemctl --user restart openclaw.service`
5. `systemctl --user status n8n.service --no-pager`
6. `systemctl --user status openclaw.service --no-pager`

## Persistence (what survives restarts)

Short answer: right now, yes, persistence is the mounted n8n data dir.

- `homelab/data/n8n` is mounted into the container as `/home/node/.n8n`.
- That directory keeps n8n state (including SQLite DB by default), config, and keys.
- If that directory is deleted, n8n starts like a fresh install.
- `~/.config/containers/systemd/n8n.env` is also important persistent config (especially secrets), but it is config, not app data.

If you later move n8n to Postgres:

- Persistence is no longer only one place.
- You will have at least two important persistent stores:
  - n8n dir (`homelab/data/n8n`) for local n8n files/keys
  - Postgres data volume/dir for workflow and execution records
- In `n8n.env`, switch DB settings to Postgres (`DB_TYPE=postgresdb` and `DB_POSTGRESDB_*` values).
- Restart after env changes: `systemctl --user restart n8n.service`

Rule of thumb for backups:

- SQLite mode (today): back up `homelab/data/n8n` and `~/.config/containers/systemd/n8n.env`.
- Postgres mode (future): back up Postgres data/dumps plus `homelab/data/n8n` and `~/.config/containers/systemd/n8n.env`.

## Layout

- `n8n/n8n.container` - n8n service definition
- `n8n/n8n.env.example` - environment template for n8n
- `openclaw/openclaw.container` - OpenClaw service definition
- `openclaw/openclaw.env.example` - environment template for OpenClaw
- `networks/homelab.network` - shared podman network
- `scripts/install-quadlets.sh` - install/copy into Quadlet directory
- `data/` - local persistent state (gitignored)

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

## Environment variables

- n8n reads env vars from `~/.config/containers/systemd/n8n.env` via `EnvironmentFile=` in `homelab/n8n/n8n.container`.
- First-time setup: `cp homelab/n8n/n8n.env.example ~/.config/containers/systemd/n8n.env`
- Edit values in `~/.config/containers/systemd/n8n.env` for your host (timezone, URL, webhook, cookie behavior).
- After changing env vars, apply with: `systemctl --user restart n8n.service`
- Keep secrets only in `~/.config/containers/systemd/n8n.env` (never commit them to git).

Common vars in `n8n.env`:

- `TZ` / `GENERIC_TIMEZONE`: workflow timezone.
- `N8N_HOST`, `N8N_PORT`, `N8N_PROTOCOL`: base URL components used by n8n.
- `WEBHOOK_URL`: external URL used in webhook callbacks.
- `N8N_SECURE_COOKIE`: set `false` for local HTTP testing, set `true` when behind HTTPS.
- `EXECUTIONS_DATA_PRUNE` / `EXECUTIONS_DATA_MAX_AGE`: execution retention policy.

Common vars in `openclaw.env`:

- `OPENCLAW_GATEWAY_TOKEN`: required token for Control UI access.
- `GROQ_API_KEY` / `OPENAI_API_KEY` / `OLLAMA_API_KEY`: optional provider credentials.

## How `~/.config/containers/systemd` works

- For rootless Quadlet, systemd reads unit definitions from `~/.config/containers/systemd` (your user-level config, not repo-managed by default).
- In this repo, `homelab/*.container` and `homelab/*.network` are source files; `./homelab/scripts/install-quadlets.sh` copies rendered files into `~/.config/containers/systemd`.
- Expect `~/.config/containers/systemd/n8n.container`, `~/.config/containers/systemd/openclaw.container`, and `~/.config/containers/systemd/homelab.network` to be overwritten on each install run.
- Expect `~/.config/containers/systemd/n8n.env` and `~/.config/containers/systemd/openclaw.env` to be preserved after first creation (script only creates them if missing).
- After install, script runs `systemctl --user daemon-reload` and enables/starts services so changes are picked up.
- The network unit is started (not enabled) because Quadlet may generate it as transient; this avoids `...is transient or generated` errors.
- On some systems, service units are treated as generated/transient and cannot be enabled; the script falls back to `start` so install still succeeds.

What to sync and how often:

- Sync repo config (`git pull` + rerun install script) whenever you change Quadlet files in `homelab/`, switch branches, or pull homelab updates.
- For normal operation, no periodic sync is required if nothing changed.
- Keep host-specific values and secrets in `~/.config/containers/systemd/n8n.env`; update only when your host/domain/secrets change.
- A practical cadence is event-based (on config changes), plus an optional monthly review to rotate credentials and confirm env values.

Recommended update flow:

1. `git pull`
2. `./homelab/scripts/install-quadlets.sh`
3. `systemctl --user restart n8n.service`
4. `systemctl --user restart openclaw.service`
5. `systemctl --user status n8n.service`
6. `systemctl --user status openclaw.service`

## Common commands

- `systemctl --user status n8n.service`
- `journalctl --user -u n8n.service -n 100 --no-pager`
- `systemctl --user restart n8n.service`
- `systemctl --user stop n8n.service`
- `systemctl --user status openclaw.service`
- `journalctl --user -u openclaw.service -n 100 --no-pager`
- `systemctl --user restart openclaw.service`
- `systemctl --user stop openclaw.service`

## Notes

- This setup is rootless and uses your user systemd instance.
- The install script writes an absolute `Volume=` path to `homelab/data/n8n` in this repo.
- If you want auto-updates, enable the timer:
  - `systemctl --user enable --now podman-auto-update.timer`
