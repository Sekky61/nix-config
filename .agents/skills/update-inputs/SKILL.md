---
name: update-inputs
description: Update flake inputs safely, use when a system or package update has been requested
---

Use this skill when updating dependencies in `flake.lock`.

Scenarios:
1) Update inputs to the latest available versions:
   - `nix flake update`
2) If only one input should be updated, run:
   - `nix flake update nixpkgs`, `nix flake update nixpkgs opencode`
3) If the latest version of an input is broken, pin that input to a known-good commit:
   - `nix flake lock --override-input opencode github:anomalyco/opencode/62a24c2`

Notes
- Commit only `flake.lock` (and `flake.nix` only if input definitions changed).
- Commit name should be `flake: update` or `flake: update opencode` or similar
- Keep overrides narrow to the affected input instead of broad changes.
