# AGENTS.md

## Build & Test

- Build system: `scripts/test-build` (uses `nix build .#nixosConfigurations.$(hostname -s).config.system.build.toplevel`)
- Flake check: `scripts/flake-check` (runs `nix flake check --impure`)
- Format Nix: `scripts/format` (`nix fmt *.nix`)

## Single Test

To run a specific build/test target:
```
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

## Code Style Guidelines

- Nix: 2-space indent, snake-case filenames, `default.nix` entrypoints
- Bash: `set -euo pipefail` in scripts, lowercase vars with underscores
- Lua (Neovim): stylua.toml (2-space indent, single quotes)
- Imports: use relative paths (`./module`), list imports at top of flake or file
- Naming: modules and attributes in lowercase or camelCase; files and folders kebab-case
- Error handling: strict flags in shell, explicit error messages in Nix modules
- Document only the non-obvious

## Additional Rules

- `michal-unstable` usage:
  - Prefer `pkgs` by default for system packages and stable/shared tooling.
  - Use `michal-unstable` for fast-moving daily coding tools that benefit from newer versions (e.g. `code-cursor`, `graphite-cli`, similar editor/AI/dev CLI tools). Fast-moving software
  - Keep scope narrow: only pull specific packages from `michal-unstable`, do not switch whole modules/services to it.
  - Access it via pkgs (`pkgs.michal-unstable`)

