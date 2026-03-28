import { Args, Command } from '@effect/cli'
import * as Options from '@effect/cli/Options'
import { Console, Effect } from 'effect'
import { discoverNetworks, discoverServices } from '../lib/discovery'

const resourceArgument = Args.text({ name: 'resource' }).pipe(Args.withDefault(null))
const isJsonOutputOption = Options.boolean('json').pipe(Options.withDescription('Print JSON output'))

export const list = Command.make(
  'list',
  { isJsonOutput: isJsonOutputOption, resource: resourceArgument },
  ({ isJsonOutput, resource }) =>
    Effect.gen(function* () {
      const services = resource === 'networks' ? [] : yield* discoverServices
      const networks = resource === 'services' ? [] : yield* discoverNetworks

      if (resource && resource !== 'services' && resource !== 'networks') {
        yield* Effect.fail(new Error(`Unknown list target: ${resource}`))
      }

      if (isJsonOutput) {
        yield* Console.log(JSON.stringify({ networks, services }, null, 2))
        return
      }

      if (services.length > 0) {
        yield* Console.log('Services')

        for (const service of services) {
          const resources = [
            `live=${service.hasLiveContainerFile ? 'yes' : 'no'}`,
            `env=${service.hasEnvExample ? (service.hasEnvFile ? 'yes' : 'missing') : 'n/a'}`,
            `data=${service.hasDataDir ? 'yes' : 'missing'}`
          ]
          yield* Console.log(`- ${service.name}: ${service.description}`)
          yield* Console.log(`  ${resources.join('  ')}`)

          if (service.urls.length > 0) {
            yield* Console.log(`  urls: ${service.urls.join(', ')}`)
          }
        }
      }

      if (services.length > 0 && networks.length > 0) {
        yield* Console.log('')
      }

      if (networks.length > 0) {
        yield* Console.log('Networks')

        for (const network of networks) {
          yield* Console.log(`- ${network.name}: live=${network.hasLiveFile ? 'yes' : 'no'}`)
        }
      }
    })
).pipe(Command.withDescription('List services, networks, and detected resources'))
