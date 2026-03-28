#!/usr/bin/env bun

import { Command } from "@effect/cli"
import { BunContext, BunRuntime } from "@effect/platform-bun"
import { Effect } from "effect"
import pkg from "../package.json" with { type: "json" }
import { status } from "./commands/status"

const command = Command.make(pkg.name, {}, () => Effect.void).pipe(
  Command.withDescription("Homelab utility CLI"),
  Command.withSubcommands([status])
)

const cli = Command.run(command, {
  executable: "homelab",
  name: "Homelab",
  version: pkg.version
})

cli(process.argv).pipe(Effect.provide(BunContext.layer), BunRuntime.runMain())
