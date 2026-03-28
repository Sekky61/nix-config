# homelab

Phase-one shell for the `homelab` CLI described in `../cli-spec.md`.

This app was bootstrapped from the `eos-utils` Effect.ts CLI and intentionally reduced to the smallest reusable setup:

- one entry point
- one real subcommand
- test wiring kept in place

## Quick start

```sh
cd homelab/cli
bun install
bun run src/bin.ts --help
```

## Current command surface

```sh
homelab status
```

The current implementation is intentionally small. `status` discovers services from `../`, computes basic health, and serves as the reference shape for the next subcommands.

## Structure

- `src/bin.ts` - CLI bootstrap
- `src/commands/status.ts` - first real subcommand
- `src/lib/discovery.ts` - repo scanning and health logic
- `src/lib/runtime.ts` - shell/process helpers
- `test` - phase-one test setup

## Development

```sh
bun run check
bun run test
```
