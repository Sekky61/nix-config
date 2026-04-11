---
name: maintenance-routine
description: Orchestrate routine system maintenance for this nix config, including previewing updates, updating inputs, building, and applying changes
---

Use this skill when the user talks to the machine at a high level, for example:
- "check for updates"
- "update just the dev tools"
- "update and apply if it builds"
- "prepare a safe update for nixpi"

This is an orchestration skill. Route to narrower skills and repo scripts instead of inventing a new flow.

## Routing

- For "what would change?" or "is it safe to update?":
  - use `maintenance-check`
- For changing flake inputs:
  - use `update-inputs`
- For local preflight build:
  - use `scripts/test-build`
  - or `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` for a named host
- For applying the update:
  - use `scripts/update`

## Default flows

### Check only

1. Decide whether the user wants:
   - a lightweight input preview
   - or a concrete package-level diff like `nh os switch`
2. Run the `maintenance-check` flow at the appropriate depth.
   - lightweight:
     - lockfile preview in a temporary copy
   - concrete package diff:
      - `nh os switch -n -d always .`
   - hypothetical post-update package diff:
      - `nh os switch -n -d always -u --no-write-lock-file .`
3. Report stale inputs, unusual inputs, package-level impact, and warnings.
4. Split warnings into:
   - easy cleanup items the agent can usually fix directly
   - harder items that may need design choices or broader review
5. If `nh` dirtied `flake.lock` during a preview, revert it immediately and mention the caveat.

### Update only

1. Decide whether the user asked for all inputs or a subset.
2. Use `update-inputs`.
3. Summarize the `flake.lock` diff.

### Update and build

1. Use `update-inputs`.
2. Run `scripts/test-build` for the current host unless the user named another host.
3. Fix small breakages directly.
4. Stop and report bigger evaluation or packaging issues.

### Update and apply

1. Use `update-inputs`.
2. Build first unless the user explicitly waived that check.
3. Apply with `scripts/update`.
4. Choose flags carefully:
   - current host, pure: `scripts/update`
   - current host, impure: `scripts/update --impure`
   - named remote host: `scripts/update --remote --hostname=<host>`

## Host assumptions

- If no host is named, assume the current machine.
- If the user names `nixpi` or another remote host, avoid local-switch commands and use the remote update path.
- Be explicit when the target is impure, because this repo has a dedicated impure switch path.

## Guardrails

- Inspect `git status --short` before changing files.
- Do not overwrite unrelated work in the tree.
- Do not switch the system as part of a "check" request.
- When a PR ref, fork, or pin is involved, mention that the update may need manual review.
- When using `nh -u` or `nh -U` for a read-only preview, verify whether `flake.lock` changed anyway.
- For safer automation, consider a temporary repo copy plus plain `nix build --dry-run --json` instead of `nh`.
- Keep the user-facing report short and operational: what changed, whether it built, whether it was applied, and any follow-up.
