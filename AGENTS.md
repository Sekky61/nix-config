# AGENTS.md

## Workflow

- I ask you for a thing
- You do the thing, using patterns you find in the codebase
- You do not test by default, only in specific circumstances

## Build & Test

- Build system: `scripts/test-build` (uses `nix build .#nixosConfigurations.$(hostname -s).config.system.build.toplevel`)
- Flake check: `scripts/flake-check` (runs `nix flake check --impure`)
- Format Nix: `scripts/format` (`nix fmt *.nix`)

To run a specific build/test target:
```
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

## Code Style Guidelines

- Nix: 2-space indent, snake-case filenames, `default.nix` entrypoints
- Imports: use relative paths (`./module`), list imports at top of flake or file
- Document only the non-obvious

- Bash:
  - `set -euo pipefail` in scripts, lowercase vars with underscores
  - Error handling: strict flags in shell, explicit error messages in Nix modules

- Lua (Neovim):
  - stylua.toml (2-space indent, single quotes)

## Additional Facts

- `michal-unstable` flake input usage:
  - More frequently updated input
  - Use it for hot, fast-moving daily coding tools that benefit from newer versions (e.g. `code-cursor`, `graphite-cli`, editor/AI/dev CLI tools)
  - Keep scope narrow: only pull specific packages from `michal-unstable`, do not switch whole modules/services to it
  - Access it via pkgs (`pkgs.michal-unstable`)

