# Homelab CLI Spec

The util `homelab`

## Why this exists

The old shell workflow mixed several jobs into one flow:

- discover source files in the repo
- render live Quadlet files into `~/.config/containers/systemd`
- initialize missing env files
- reload user systemd
- start services
- optionally change autostart state

That works for a single service, but it hides the actual model of the system. The next iteration should expose a single, obvious `homelab` command that tells you what exists, what state it is in, and what actions are available.

This doc defines the CLI API and the implementation shape for the first version. It should be useful both while building the tool and later as the user-facing command reference.

## Goals

- Provide one entrypoint: `homelab`
- Make the command self-documenting with strong `--help`
- Surface all day-to-day actions from one place
- Separate read-only inspection from state-changing actions
- Work with multiple services, not just `n8n`
- Keep repo files as source of truth and make that visible in the UX
- Be easy to extend when new services are added under `homelab/`
- Integrate health checks into normal commands instead of hiding them behind a separate tool

## Non-goals

- Replacing Podman, systemd, or Quadlet concepts
- Hiding every low-level detail from advanced users
- Managing secrets directly
- Reopening the implementation language choice

## Mental model

The CLI should teach these layers clearly:

1. Source: files in `homelab/` tracked in git
2. Live config: rendered/copied files in `~/.config/containers/systemd/`
3. Runtime: user systemd units and Podman containers
4. Persistent data: directories under `homelab/data/`

Most commands should map cleanly to one of these layers.

## Primary entities

- Service: a directory like `homelab/n8n/` with `<name>.container` and optional `<name>.env.example`
- Network: a file in `homelab/networks/*.network`
- Env file: live config file in `~/.config/containers/systemd/<service>.env`
- Data dir: `homelab/data/<service>`

Service and network discovery should be automatic by scanning the repo layout.

## Command design principles

- Prefer `homelab <noun> <verb>` over special-purpose script names
- Have one canonical write path: `apply`
- Support both human-readable output and `--json`
- Keep defaults safe and unsurprising
- Make status, health, and next actions obvious
- Allow targeting one service or all services

## Proposed top-level UX

Top-level help:

```text
Usage:
  homelab <command> [args]

Commands:
  list         List services, networks, and detected resources
  status       Show current state of services and homelab resources
  apply        Sync repo state into live Quadlets and optionally start services
  service      Service lifecycle and inspection commands
  env          Manage env files for services
  open         Open a service URL in the browser
  paths        Show important homelab paths
  help         Show help for a command

Global flags:
  --json       Machine-readable output
  --quiet      Reduce output
  --verbose    Show more detail
  --dry-run    Show actions without changing state
  -h, --help   Show help
```

## Command groups

### `homelab list`

Purpose: answer "what do I have?"

Examples:

- `homelab list`
- `homelab list services`
- `homelab list networks`
- `homelab list --json`

Expected output fields:

- service name
- description
- source container file
- live container file presence
- env file presence
- data dir presence
- exposed URL or port if known

Notes:

- Default output should be compact and table-like
- `--json` should expose structured metadata for scripting

### `homelab status`

Purpose: answer "what is healthy right now?"

Examples:

- `homelab status`
- `homelab status n8n`
- `homelab status --json`

Default behavior:

- With no service name, show all services plus shared resources
- Include network status if relevant

Suggested status columns:

- service
- installed
- enabled
- active
- container state
- health
- url
- notes

Integrated health checks:

- `status` should include prerequisite and runtime health in its output
- a missing env file, missing data dir, failed unit, or broken runtime should show up as `warn` or `fail`
- the default output should suggest the next likely action, for example `homelab apply n8n` or `homelab env init n8n`

### `homelab apply`

Purpose: replace `install-quadlets.sh` with one explicit reconcile command.

Responsibilities:

- validate prerequisites
- create missing live directories
- create missing data dirs
- copy or render source files into live Quadlet files
- initialize missing env files from examples
- reload user systemd
- optionally start/restart affected resources
- optionally change autostart mode

Examples:

- `homelab apply`
- `homelab apply n8n`
- `homelab apply --autostart on`
- `homelab apply --reload-only`
- `homelab apply --dry-run`

Flags:

- `--autostart on|off|keep` - same semantic meaning as today
- `--start` - start affected services after reload; default `true`
- `--reload-only` - sync files and daemon-reload, do not start services
- `--force` - overwrite generated/live artifacts even if drift is detected

Behavior notes:

- Running `homelab apply` with no args should apply all discovered services
- Running `homelab apply <service>` should apply just one service plus required shared resources
- The command should print a short plan before executing, unless `--quiet`
- After execution, the command should print post-apply health for affected services

### `homelab service`

Purpose: lifecycle control for one or more services.

Subcommands:

- `homelab service list`
- `homelab service info <service>`
- `homelab service start <service>`
- `homelab service stop <service>`
- `homelab service restart <service>`
- `homelab service enable <service>`
- `homelab service disable <service>`
- `homelab service status <service>`

Notes:

- `homelab status <service>` can be a shorthand for `homelab service status <service>`
- `enable` and `disable` should manage systemd autostart only
- `info` should summarize source path, live path, env path, data path, URL, ports, dependencies, and current unit state
- `status` should expose the same health model as top-level `homelab status`, scoped to one service

### `homelab env`

Purpose: make env-file management discoverable instead of tribal knowledge.

Subcommands:

- `homelab env list`
- `homelab env path <service>`
- `homelab env init <service>`
- `homelab env edit <service>`
- `homelab env diff <service>`

Expected behavior:

- `init` copies `<service>.env.example` only if the live env file is missing
- `path` prints the live env path only, suitable for shell usage
- `edit` opens `$EDITOR` on the live env file
- `diff` compares example and live env keys, not secret values

### `homelab open`

Purpose: open the UI for a service without remembering ports.

Examples:

- `homelab open n8n`

Behavior:

- use known URL metadata if available
- fail with a clear message if no URL is defined for the service

### `homelab paths`

Purpose: quickly print important paths.

Examples:

- `homelab paths`
- `homelab paths n8n`

Suggested output:

- repo root
- homelab root
- live Quadlet dir
- service source dir
- service live unit path
- service env path
- service data dir

## Service metadata model

The CLI needs stable metadata to drive help, `list`, `open`, and `info`.

Phase 1 should derive as much as possible from existing files:

- name from `<service>.container`
- description from Quadlet `[Unit] Description=`
- env support from presence of `<service>.env.example`
- ports and URL hints from `PublishPort=` and known defaults

Phase 2 can add an optional metadata file per service, for example:

- `homelab/<service>/service.json`
- or `homelab/<service>/default.nix`
- or `homelab/<service>/metadata.sh`

The exact file format can be decided during implementation, but the shape should stay stable regardless of storage format.

Minimum metadata fields the CLI should expose internally:

- `name`
- `description`
- `container_file`
- `env_example_file`
- `live_env_file`
- `data_dir`
- `urls`
- `ports`
- `depends_on`
- `has_autoupdate`

## Health model

Health should be a first-class concept in the CLI, not a separate command.

Each service should evaluate a small, consistent set of checks:

- source container file exists
- live Quadlet file exists
- env file exists when required
- data dir exists when required
- user unit is loadable
- user unit active state
- user unit enablement state
- container runtime state when inspectable
- URL reachability when cheap and configured

Suggested aggregate states:

- `ok` - service is configured and running as expected
- `warn` - service is usable but something needs attention
- `fail` - service is broken or cannot start correctly
- `unknown` - state cannot be determined

Health should appear in:

- `homelab status`
- `homelab service status <service>`
- final output of `homelab apply`
- `homelab service info <service>`

Implementation note:

- expensive checks should be optional or bounded by a short timeout
- default health checks should stay fast enough for frequent interactive use

## Output conventions

- Human output should be concise and action-oriented
- Errors should always suggest the next likely fix
- `--json` should be available on `list`, `status`, `service info`, and `paths`
- Exit code `0` means success, non-zero means command failure

Suggested exit codes:

- `0` success
- `1` generic runtime failure
- `2` bad CLI usage
- `3` missing prerequisite
- `4` unknown service
- `5` unhealthy service state

## Help design

Every command should have short examples in help output.

Example:

```text
$ homelab service restart --help

Restart one homelab service.

Usage:
  homelab service restart <service>

Examples:
  homelab service restart n8n
  homelab service restart n8n --wait

Flags:
  --wait      Wait until the service becomes active
  --timeout   Maximum seconds to wait
```

## Recommended aliases and shortcuts

These are optional, but useful if the implementation supports them:

- `homelab ls` -> `homelab list`
- `homelab st` -> `homelab status`
- `homelab svc` -> `homelab service`
- `homelab ps` -> `homelab status`

Keep aliases secondary in help text; canonical commands should stay obvious.

## Migration from the old shell scripts

Desired mapping:

- `install-quadlets.sh` -> `homelab apply`
- `homelab-autostart on` -> `homelab service enable <service>` or `homelab apply --autostart on`
- `homelab-autostart off` -> `homelab service disable <service>` or `homelab apply --autostart off`
- `systemctl --user status n8n.service` -> `homelab status n8n`

Migration status:

1. `homelab apply` replaces the old install flow
2. docs now point to `homelab`
3. the old shell scripts have been removed

## Implementation constraints the API should respect

- Rootless Podman and user systemd remain the execution model
- Source of truth stays in `homelab/` inside the repo
- Live files stay in `~/.config/containers/systemd/`
- Secrets remain outside git
- The CLI should not require Nix evaluation for normal day-to-day operations

## Implementation shape

The implementation stack for this tool is `Effect.ts`.

Why:

- it fits a command-oriented workflow with typed errors and composable effects
- it makes dependency injection for filesystem, process execution, and clock concerns straightforward
- it matches an existing reference implementation, reducing design risk

Recommended internal modules:

- `cli` - command definitions, args, help text, rendering
- `domain` - service, network, path, and health models
- `discovery` - repo scanning and metadata extraction
- `quadlet` - render/copy logic for live files
- `systemd` - `systemctl --user` queries and lifecycle operations
- `podman` - runtime inspection when needed
- `env` - env file init, edit, and key diff behavior
- `health` - check definitions and status aggregation
- `output` - table, plain text, and json rendering

Recommended service boundaries in Effect terms:

- `FileSystem`
- `ProcessRunner`
- `Clock`
- `Platform`
- `Editor`
- `Browser`
- `HomelabDiscovery`
- `HomelabRuntime`

Implementation guidance:

- keep command handlers thin; push logic into reusable effectful services
- model user-facing failures as typed domain errors, not ad-hoc strings
- define a single service metadata schema and reuse it across `list`, `status`, `info`, and `apply`
- define a single health result schema and reuse it everywhere
- make `--json` output come from the same domain objects as human output
- keep shelling out to `systemctl` and `podman` behind narrow adapters

## Open questions

These remain open for implementation planning:

- whether service metadata should stay implicit or get an explicit manifest
- whether shell completion ships in phase 1 or phase 2
- whether `open` should depend on `xdg-open`, `open`, or a small abstraction layer
- how much config drift detection we want in `apply`
- whether URL health checks are opt-in, default-on, or per-service configurable

## Recommended phase 1 scope

If we want a small but strong first version, ship this set first:

- `homelab help`
- `homelab list`
- `homelab status [service]`
- `homelab apply [service] [--autostart ...]`
- `homelab service start|stop|restart|enable|disable <service>`
- `homelab service info|status <service>`
- `homelab env path|init|edit <service>`
- integrated health checks in `status` and `apply`

That already covers almost every action that used to be spread across README knowledge, the old shell scripts, and raw `systemctl` commands.
