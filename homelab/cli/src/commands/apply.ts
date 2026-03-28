import { Args, Command } from '@effect/cli'
import * as Options from '@effect/cli/Options'
import { Console, Effect } from 'effect'
import {
  copyFileTo,
  copyIfMissing,
  discoverNetworks,
  ensureDirectory,
  findService,
  getHomelabPaths,
  renderServiceContainer,
  selectServices
} from '../lib/discovery'
import { runCommand } from '../lib/runtime'

type AutostartMode = 'keep' | 'off' | 'on'

const serviceArgument = Args.text({ name: 'service' }).pipe(Args.withDefault(null))
const autostartOption = Options.text('autostart').pipe(
  Options.withDefault('keep' as const),
  Options.withDescription('Autostart mode: on, off, or keep')
)
const startOption = Options.boolean('start').pipe(Options.withDescription('Start affected services after reload'))
const reloadOnlyOption = Options.boolean('reload-only').pipe(Options.withDescription('Sync files and reload without starting services'))
const dryRunOption = Options.boolean('dry-run').pipe(Options.withDescription('Show actions without changing state'))

const validateAutostartMode = (value: string) => {
  if (value === 'keep' || value === 'off' || value === 'on') {
    return value satisfies AutostartMode
  }

  throw new Error(`Invalid autostart mode: ${value}`)
}

const applyAutostart = (serviceName: string, autostartMode: AutostartMode) => {
  if (autostartMode === 'keep') {
    return Effect.void
  }

  return runCommand('systemctl', ['--user', autostartMode === 'on' ? 'enable' : 'disable', `${serviceName}.service`]).pipe(
    Effect.asVoid,
    Effect.catchAll(() => Effect.void)
  )
}

export const apply = Command.make(
  'apply',
  {
    autostart: autostartOption,
    dryRun: dryRunOption,
    reloadOnly: reloadOnlyOption,
    serviceName: serviceArgument,
    start: startOption
  },
  ({ autostart, dryRun, reloadOnly, serviceName, start }) =>
    Effect.gen(function* () {
      const autostartMode = validateAutostartMode(autostart)
      const homelabPaths = getHomelabPaths()
      const networks = yield* discoverNetworks
      const services = yield* selectServices(serviceName)
      const shouldStartServices = reloadOnly ? false : start || !reloadOnly
      const plan = [
        `ensure ${homelabPaths.liveQuadletDir}`,
        ...services.map((service) => `ensure ${service.dataDir}`),
        ...networks.map((network) => `copy ${network.sourceFile} -> ${network.liveFile}`),
        ...services.map((service) => `render ${service.containerFile} -> ${service.liveContainerFile}`),
        ...services
          .filter((service) => service.envExampleFile)
          .map((service) => `init env if missing ${service.liveEnvFile}`),
        'systemctl --user daemon-reload',
        'systemctl --user start homelab-network.service',
        ...services.map((service) => `systemctl --user ${shouldStartServices ? 'start' : 'skip'} ${service.name}.service`)
      ]

      yield* Console.log('Plan')
      for (const step of plan) {
        yield* Console.log(`- ${step}`)
      }

      if (dryRun) {
        return
      }

      yield* ensureDirectory(homelabPaths.liveQuadletDir)

      for (const service of services) {
        yield* ensureDirectory(service.dataDir)
      }

      for (const network of networks) {
        yield* copyFileTo({ destination: network.liveFile, source: network.sourceFile })
      }

      for (const service of services) {
        yield* renderServiceContainer(service)

        if (service.envExampleFile) {
          yield* copyIfMissing({ destination: service.liveEnvFile, source: service.envExampleFile })
        }
      }

      yield* runCommand('systemctl', ['--user', 'daemon-reload'])
      yield* runCommand('systemctl', ['--user', 'start', 'homelab-network.service']).pipe(
        Effect.asVoid,
        Effect.catchAll(() => Effect.void)
      )

      for (const service of services) {
        yield* applyAutostart(service.name, autostartMode)

        if (shouldStartServices) {
          yield* runCommand('systemctl', ['--user', 'start', '--no-block', `${service.name}.service`])
        }
      }

      yield* Console.log('')
      yield* Console.log('Post-apply status')

      for (const service of services) {
        const refreshedService = yield* findService(service.name)
        yield* Console.log(
          `- ${refreshedService.name}: health=${refreshedService.health} active=${refreshedService.activeState ?? 'unknown'} enabled=${refreshedService.enabledState ?? 'unknown'}`
        )
      }
    })
).pipe(Command.withDescription('Sync repo state into live Quadlets and optionally start services'))
