## Goal

Maintain a “single place to run everything” in your dotfiles repo: reproducible provisioning steps, one command to start/stop, and a repeatable checklist for adding new services.

---

## Proposed layout in your dotfiles repo

Put this under something like `dotfiles/docker/`:

```
dotfiles/
  docker/
    README.md
    Makefile
    .env.example
    compose.base.yaml
    services/
      traefik.compose.yaml        # optional but recommended reverse proxy
      postgres.compose.yaml       # example shared db
      yourapp.compose.yaml        # your app(s)
      ...
    data/                         # bind mounts (owned by you)
      traefik/
      postgres/
      ...
    scripts/
      bootstrap.sh
      env-init.sh
      backup.sh
      restore.sh
      update-images.sh
```

Notes:

* Commit `*.example`, compose YAML, scripts, and docs.
* Do **not** commit `.env`, secrets, or any database content.
* Keep persistent state in `docker/data/` (bind mounts) or named volumes (but bind mounts are easier to back up from a dotfiles-managed folder).

---

## Core operational model

Use layered compose files:

* `compose.base.yaml` = shared networks, common settings, maybe monitoring
* `services/*.compose.yaml` = one file per service (clean onboarding and modularity)

Run with:

* `docker compose -f compose.base.yaml -f services/postgres.compose.yaml up -d`
* or combine multiple `-f services/*.compose.yaml` as needed.

This keeps “add a new service” low-friction and avoids a single giant compose file.

---

## Files to create

### 1) `compose.base.yaml` (shared network + defaults)

```yaml
name: dotfiles-stack

networks:
  edge:
    name: edge
  internal:
    name: internal
    internal: true
```

(You can add shared logging options here later, but keep it minimal initially.)

---

### 2) Example service: `services/postgres.compose.yaml`

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    networks: [internal]
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB"]
      interval: 5s
      timeout: 3s
      retries: 20
    restart: unless-stopped
```

---

### 3) Optional reverse proxy (recommended): `services/traefik.compose.yaml`

If you want “one entrypoint” (and later TLS), add Traefik; otherwise skip.

```yaml
services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    networks: [edge, internal]
    ports:
      - "80:80"
      - "443:443"
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data/traefik:/etc/traefik
    restart: unless-stopped
```

Then each service that should be reachable externally gets Docker labels.

---

### 4) `.env.example` (template, committed)

```bash
# Shared
TZ=America/Chicago

# Postgres
POSTGRES_DB=app
POSTGRES_USER=app
POSTGRES_PASSWORD=change_me
POSTGRES_PORT=5432

# Example app
APP_PORT=3000
APP_DATABASE_URL=postgresql://app:change_me@postgres:5432/app
```

Local `.env` (not committed) is created from this.

---

### 5) `scripts/env-init.sh` (create `.env` + strong secrets)

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -f .env ]]; then
  echo ".env already exists"
  exit 0
fi

cp .env.example .env

# Replace obvious placeholders (simple approach)
if command -v openssl >/dev/null 2>&1; then
  pw="$(openssl rand -base64 24 | tr -d '\n')"
  # macOS vs GNU sed compatibility:
  if sed --version >/dev/null 2>&1; then
    sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$pw/" .env
  else
    sed -i "" "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$pw/" .env
  fi
fi

echo "Created .env"
```

---

### 6) `scripts/bootstrap.sh` (new machine provisioning checklist-as-code)

Keep it “check + instruct”, not a massive installer:

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== Docker sanity checks =="
docker version >/dev/null
docker compose version >/dev/null

echo "== Create data dirs =="
mkdir -p data/{postgres,traefik}

echo "== Create env if missing =="
./scripts/env-init.sh

echo "Bootstrap complete."
echo "Next: make up STACK='traefik postgres'"
```

---

### 7) `Makefile` (one command UX)

```make
SHELL := /usr/bin/env bash
.ONESHELL:

BASE := -f compose.base.yaml
STACK ?= postgres
FILES := $(foreach s,$(STACK),-f services/$(s).compose.yaml)

.PHONY: up down ps logs restart pull update bootstrap

bootstrap:
	./scripts/bootstrap.sh

up:
	docker compose $(BASE) $(FILES) --env-file .env up -d --remove-orphans

down:
	docker compose $(BASE) $(FILES) --env-file .env down

ps:
	docker compose $(BASE) $(FILES) --env-file .env ps

logs:
	docker compose $(BASE) $(FILES) --env-file .env logs -f --tail=200

restart:
	docker compose $(BASE) $(FILES) --env-file .env restart

pull:
	docker compose $(BASE) $(FILES) --env-file .env pull

update: pull up
```

Usage examples:

* `make bootstrap`
* `make up STACK="traefik postgres yourapp"`
* `make logs STACK="yourapp"`
* `make update STACK="traefik postgres yourapp"`

---

## README.md content (what you want documented)

Include these sections (copy/paste structure):

### Provisioning a new machine

1. Install Docker Engine + Docker Compose v2.
2. Ensure Docker daemon is running.
3. Clone dotfiles repo and apply your dotfiles manager (chezmoi/stow/etc.).
4. `cd dotfiles/docker`
5. `make bootstrap`
6. `make up STACK="traefik postgres <others>"`

### Routine operations

* Start: `make up STACK="..."`
* Stop: `make down STACK="..."`
* Status: `make ps STACK="..."`
* Logs: `make logs STACK="..."`

### Backups (minimum viable)

Add `scripts/backup.sh` to create timestamped tarballs of `data/` plus DB dumps.

A basic pattern:

* For Postgres: `docker exec postgres pg_dump ... > backups/...sql`
* For bind-mounted volumes: `tar -czf backups/data-YYYYmmdd.tgz data/`

Also document restore steps via `scripts/restore.sh`.

### Updating images safely

* `make update STACK="..."` (pull + recreate)
* If a service needs migrations, document a `make migrate` target per service.

---

## “Add a new service” checklist (repeatable tasks)

For each new service `X`:

1. Create `services/x.compose.yaml`
2. Decide persistence:

   * Bind-mount under `data/x` (preferred for simple backups), or
   * Named volumes (ok, but document how you back them up)
3. Add `X_*` environment variables to `.env.example`
4. Add a minimal healthcheck if the service supports it
5. If exposed externally:

   * attach to `edge` network
   * add Traefik labels (or document port mapping if no proxy)
6. Add one README section:

   * What it does
   * `make up STACK="... x ..."`
   * Any first-run initialization steps
7. If it needs initialization/migrations:

   * Add a script `scripts/x-init.sh` and/or Makefile target

---

## Opinionated defaults that keep this “simple Docker”

* Prefer bind mounts under `docker/data/` for persistence.
* Keep `.env` local-only and generated from `.env.example`.
* Don’t build images until you must; start with official images + config.
* Add reverse proxy only if you need multiple HTTP services or want clean host ports.

If you tell me which concrete services you’re running (names + whether they need public HTTP access), I can draft the initial `services/*.compose.yaml` set with sensible networks, volumes, and Makefile targets.
