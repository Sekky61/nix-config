import { Args, Command } from "@effect/cli"
import * as Options from "@effect/cli/Options"
import { Console, Effect } from "effect"
import { discoverServices } from "../lib/discovery"

const serviceArgument = Args.text({ name: "service" }).pipe(Args.withDefault(null))
const isJsonOutputOption = Options.boolean("json").pipe(Options.withDescription("Print JSON output"))

export const status = Command.make(
  "status",
  { isJsonOutput: isJsonOutputOption, serviceName: serviceArgument },
  ({ isJsonOutput, serviceName }) =>
    Effect.gen(function*() {
      const services = yield* discoverServices
      const selectedServices = serviceName ? services.filter((service) => service.name === serviceName) : services

      if (serviceName && selectedServices.length === 0) {
        yield* Effect.fail(new Error(`Unknown service: ${serviceName}`))
      }

      if (isJsonOutput) {
        yield* Console.log(JSON.stringify(selectedServices, null, 2))
        return
      }

      for (const service of selectedServices) {
        yield* Console.log(
          `- ${service.name}: health=${service.health} active=${service.activeState ?? "unknown"} enabled=${service.enabledState ?? "unknown"}`
        )

        if (service.notes.length > 0) {
          yield* Console.log(`  notes: ${service.notes.join(", ")}`)
        }

        if (service.urls.length > 0) {
          yield* Console.log(`  url: ${service.urls.join(", ")}`)
        }
      }
    })
).pipe(Command.withDescription("Show homelab service health and runtime status"))
