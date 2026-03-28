---
name: create-new-homelab-service
description: Add a simple new service under `homelab/` using the repo's Podman Quadlet pattern. Always use when creating a new homelab service.
---

# Create New Homelab Service

Keep it small and follow the existing `homelab/n8n` pattern.

Steps
1. Create `homelab/<service>/`.
2. Add `homelab/<service>/<service>.container`.
3. Add `homelab/<service>/<service>.env.example` only if the service needs env vars.
4. Make sure the service is discoverable by the CLI and follows the existing naming pattern so `homelab list`, `homelab status`, and `homelab apply` pick it up automatically.
5. Update `homelab/README.md` with the new quick-start and service URLs.

Rules
- Copy naming and formatting from `homelab/n8n/n8n.container`.
- Keep secrets out of git; only commit example env values.
- Prefer one data dir under `homelab/data/<service>` if the container needs persistence.
- Keep changes non-breaking for existing services.

Checks
- Read `homelab/README.md` and inspect an existing service such as `homelab/n8n/` first.
- If there is already a similar service, copy its structure instead of inventing a new one.
