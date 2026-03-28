import { Args, Command } from '@effect/cli'
import * as Options from '@effect/cli/Options'
import { Console, Effect } from 'effect'
import { discoverNetworks, type HomelabService, selectServices } from '../lib/discovery'

const serviceArgument = Args.text({ name: 'service' }).pipe(Args.withDefault(null))
const isJsonOutputOption = Options.boolean('json').pipe(Options.withDescription('Print JSON output'))

const renderService = (service: HomelabService) => [
  `${service.name.padEnd(16)} ${service.health.padEnd(7)} active=${(service.activeState ?? 'unknown').padEnd(8)} enabled=${service.enabledState ?? 'unknown'}`,
  service.notes.length > 0 ? `  notes: ${service.notes.join(', ')}` : null,
  service.urls.length > 0 ? `  urls: ${service.urls.join(', ')}` : null
].filter((line): line is string => line !== null)

export const status = Command.make(
  'status',
  { isJsonOutput: isJsonOutputOption, serviceName: serviceArgument },
  ({ isJsonOutput, serviceName }) =>
    Effect.gen(function* () {
      const selectedServices = yield* selectServices(serviceName)
      const networks = serviceName ? [] : yield* discoverNetworks

      if (isJsonOutput) {
        yield* Console.log(
          JSON.stringify(
            {
              networks,
              services: selectedServices
            },
            null,
            2
          )
        )
        return
      }

      if (networks.length > 0) {
        yield* Console.log('Networks')

        for (const network of networks) {
          yield* Console.log(
            `- ${network.name}: source=${network.sourceFile} live=${network.hasLiveFile ? 'present' : 'missing'}`
          )
        }

        yield* Console.log('')
      }

      for (const service of selectedServices) {
        for (const line of renderService(service)) {
          yield* Console.log(line)
        }
      }
    })
).pipe(Command.withDescription('Show homelab service health and runtime status'))
