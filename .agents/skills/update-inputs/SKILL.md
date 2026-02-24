---
name: update-inputs
description: Update flake inputs safely, use when a system or package update has been requested
---

Use this skill when updating dependencies of the flake.

## Scenarios

1) Update inputs to the latest available versions:
   - `nix flake update`
2) If only specific inputs should be updated, run:
   - `nix flake update nixpkgs`, `nix flake update nixpkgs opencode`
3) If the latest version of an input is broken, pin that input to a known-good commit:
   - `nix flake lock --override-input opencode github:anomalyco/opencode/62a24c2`
   - Use cli tools to find revisions that might be good
   - Leave a todo comment saying `# TODO Unpin later`

Then try `nh os build .`, see if it builds, fix small errors straight away (syntax, easy logic bugs), consult about bigger issues.

## Notes

- Commit only `flake.lock` (and `flake.nix` only if input definitions changed)
- Commit name should be `flake: update` or `flake: update opencode` or similar
- Keep overrides narrow to the affected input instead of broad changes
- Commit to the branch you are at

