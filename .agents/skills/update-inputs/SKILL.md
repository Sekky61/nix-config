---
name: update-inputs
description: Update flake inputs safely, use when a system or package update has been requested
---

Use this skill when the user wants to update flake inputs, either broadly or selectively.

The goal of this skill is to change the update scope cleanly. Build and switch steps belong to maintenance/build or maintenance/apply flows.

## Inputs

- Read `flake.nix` first to spot special cases before updating:
  - PR refs such as `?ref=pull/...`
  - forks and custom branches
  - inputs that intentionally follow other inputs
- If the user did not name a host, assume the current host for any later build handoff.

## Scenarios

1. Update all standard inputs:
   - `nix flake update`
2. Update only specific inputs:
   - `nix flake update nixpkgs`
   - `nix flake update nixpkgs opencode`
3. If the latest revision is broken, pin one input narrowly:
   - `nix flake lock --override-input opencode github:anomalyco/opencode/62a24c2`
   - Prefer a single-input override over broad rollback
   - Add a nearby comment in `flake.nix` only when that pin is expected to stay for a while, for example `# TODO unpin after upstream fix`
4. If the user asks for only fast-moving dev tools, prefer updating the relevant input instead of everything:
   - examples in this repo include `opencode`, `claude-code`, and similar tooling inputs

## Workflow

1. Inspect `git status --short`.
   - Do not overwrite unrelated user changes.
   - If `flake.nix` or `flake.lock` already have manual edits you do not understand, stop and ask.
2. Inspect `flake.nix` for pinned, forked, or unusual inputs.
3. Update the requested input set.
4. Review the resulting `flake.lock` diff and summarize the notable upstream movement.
5. Hand off to a build/apply step only if the user asked for it.

## Boundaries

- Default change set is `flake.lock` only.
- Change `flake.nix` only when adding, removing, or adjusting an override/pin.
- Keep overrides narrow to the affected input instead of broad changes.
- Do not run `scripts/update` from this skill unless the user explicitly asked to apply the update.

## Notes

- If a host-specific package comes from `pkgs.michal-unstable`, keep that usage narrow. Do not switch broad modules or whole systems to `michal-unstable`.
- For hypothetical update previews, do not rely on `nh -u --no-write-lock-file` to preserve the repo; observed behavior shows it may still write `flake.lock`.
- For safer previews, prefer a temporary repo copy or an explicit post-command `git diff -- flake.lock` check and immediate revert if needed.
- Preferred commit names:
  - `flake: update`
  - `flake: update nixpkgs`
  - `flake: pin opencode`
