import { Args, Command } from '@effect/cli'
import * as Options from '@effect/cli/Options'
import { Console, Effect } from 'effect'
import { findService, getHomelabPaths } from '../lib/discovery'

const serviceArgument = Args.text({ name: 'service' }).pipe(Args.withDefault(null))
const isJsonOutputOption = Options.boolean('json').pipe(Options.withDescription('Print JSON output'))

export const paths = Command.make(
  'paths',
  { isJsonOutput: isJsonOutputOption, serviceName: serviceArgument },
  ({ isJsonOutput, serviceName }) =>
    Effect.gen(function* () {
      const homelabPaths = getHomelabPaths()
      const service = serviceName ? yield* findService(serviceName) : null
      const payload = {
        repoRoot: homelabPaths.repoRoot,
        homelabRoot: homelabPaths.homelabRoot,
        liveQuadletDir: homelabPaths.liveQuadletDir,
        serviceSourceDir: service?.serviceRoot ?? null,
        serviceLiveUnitPath: service?.liveContainerFile ?? null,
        serviceEnvPath: service?.liveEnvFile ?? null,
        serviceDataDir: service?.dataDir ?? null
      }

      if (isJsonOutput) {
        yield* Console.log(JSON.stringify(payload, null, 2))
        return
      }

      yield* Console.log(`repo: ${payload.repoRoot}`)
      yield* Console.log(`homelab: ${payload.homelabRoot}`)
      yield* Console.log(`live: ${payload.liveQuadletDir}`)

      if (service) {
        yield* Console.log(`source: ${payload.serviceSourceDir}`)
        yield* Console.log(`unit: ${payload.serviceLiveUnitPath}`)
        yield* Console.log(`env: ${payload.serviceEnvPath}`)
        yield* Console.log(`data: ${payload.serviceDataDir}`)
      }
    })
).pipe(Command.withDescription('Show important homelab paths'))
