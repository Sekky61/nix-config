# homelab

Phase-one shell for the `homelab` CLI described in `../cli-spec.md`.

This app was bootstrapped from the `eos-utils` Effect.ts CLI and now implements the phase-one command surface from `../docs/cli-spec.md`.

## Quick start

```sh
cd homelab/cli
bun install
bun run start --help
```

## Current command surface

```sh
homelab list
homelab status
homelab apply [service]
homelab service <verb> <service>
homelab env <verb> <service>
homelab open <service>
homelab paths [service]
```

The CLI discovers services from `../`, derives metadata from Quadlet files, and supports both inspection and day-to-day lifecycle actions.

## Structure

- `src/bin.ts` - CLI bootstrap
- `src/commands` - command handlers for the phase-one CLI
- `src/lib/discovery.ts` - repo scanning and health logic
- `src/lib/runtime.ts` - shell/process helpers
- `test` - phase-one test setup

## Development

```sh
bun run check
bun run test
```
