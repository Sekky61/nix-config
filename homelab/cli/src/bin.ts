#!/usr/bin/env bun

import { Command } from "@effect/cli"
import { BunContext, BunRuntime } from "@effect/platform-bun"
import { Effect } from "effect"
import pkg from "../package.json" with { type: "json" }
import { apply } from './commands/apply'
import { backup } from './commands/backup'
import { env } from './commands/env'
import { list } from './commands/list'
import { open } from './commands/open'
import { paths } from './commands/paths'
import { service } from './commands/service'
import { status } from './commands/status'

const command = Command.make(pkg.name, {}, () => Effect.void).pipe(
  Command.withDescription('Homelab utility CLI'),
  Command.withSubcommands([list, status, apply, backup, service, env, open, paths])
)

const cli = Command.run(command, {
  executable: 'homelab',
  name: 'Homelab',
  version: pkg.version
})

cli(process.argv).pipe(Effect.provide(BunContext.layer), BunRuntime.runMain())
