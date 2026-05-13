import { Args, Command } from '@effect/cli'
import * as Options from '@effect/cli/Options'
import { Console, Effect } from 'effect'
import { discoverServices, findService, setServiceAutostart } from '../lib/discovery'
import { runCommand } from '../lib/runtime'

const serviceArgument = Args.text({ name: 'service' })
const isJsonOutputOption = Options.boolean('json').pipe(Options.withDescription('Print JSON output'))

const list = Command.make('list', {}, () =>
  Effect.gen(function* () {
    const services = yield* discoverServices
    for (const service of services) {
      yield* Console.log(service.name)
    }
  })
).pipe(Command.withDescription('List homelab services'))

const info = Command.make('info', { isJsonOutput: isJsonOutputOption, serviceName: serviceArgument }, ({ isJsonOutput, serviceName }) =>
  Effect.gen(function* () {
    const service = yield* findService(serviceName)

    if (isJsonOutput) {
      yield* Console.log(JSON.stringify(service, null, 2))
      return
    }

    yield* Console.log(`service: ${service.name}`)
    yield* Console.log(`description: ${service.description}`)
    yield* Console.log(`health: ${service.health}`)
    yield* Console.log(`source: ${service.containerFile}`)
    yield* Console.log(`live: ${service.liveContainerFile}`)
    yield* Console.log(`env: ${service.liveEnvFile}`)
    yield* Console.log(`data: ${service.dataDir}`)
    yield* Console.log(`urls: ${service.urls.join(', ') || '(none)'}`)
    yield* Console.log(`ports: ${service.ports.join(', ') || '(none)'}`)
    yield* Console.log(`depends on: ${service.dependsOn.join(', ') || '(none)'}`)
    yield* Console.log(`autostart: ${service.autostart ? 'yes' : 'no'}`)
    yield* Console.log(`autoupdate: ${service.hasAutoupdate ? 'yes' : 'no'}`)
    yield* Console.log(`active: ${service.activeState ?? 'unknown'}`)
    yield* Console.log(`enabled: ${service.enabledState ?? 'unknown'}`)
  })
).pipe(Command.withDescription('Show detailed service metadata and runtime status'))

const status = Command.make('status', { isJsonOutput: isJsonOutputOption, serviceName: serviceArgument }, ({ isJsonOutput, serviceName }) =>
  Effect.gen(function* () {
    const service = yield* findService(serviceName)

    if (isJsonOutput) {
      yield* Console.log(JSON.stringify(service, null, 2))
      return
    }

    yield* Console.log(`${service.name}: health=${service.health} active=${service.activeState ?? 'unknown'} enabled=${service.enabledState ?? 'unknown'}`)
    if (service.notes.length > 0) {
      yield* Console.log(`notes: ${service.notes.join(', ')}`)
    }
  })
).pipe(Command.withDescription('Show health for one service'))

const lifecycleCommand = (name: 'start' | 'stop' | 'restart' | 'enable' | 'disable', description: string) =>
  Command.make(name, { serviceName: serviceArgument }, ({ serviceName }) =>
    Effect.gen(function* () {
      const service = yield* findService(serviceName)

      if (name === 'enable' || name === 'disable') {
        const enabled = name === 'enable'
        const changed = yield* setServiceAutostart(service, enabled)
        yield* runCommand('systemctl', ['--user', 'daemon-reload'])
        yield* runCommand('systemctl', ['--user', name, `${serviceName}.service`]).pipe(
          Effect.asVoid,
          Effect.catchAll(() => Effect.void)
        )
        yield* Console.log(`${enabled ? 'enabled' : 'disabled'} ${serviceName}.service${changed ? '' : ' (already set)'}`)
        return
      }

      const result = yield* runCommand('systemctl', ['--user', name, `${serviceName}.service`])
      const output = [result.stdout.trim(), result.stderr.trim()].filter((value) => value.length > 0).join('\n')
      yield* Console.log(output || `${name}d ${serviceName}.service`)
    })
  ).pipe(Command.withDescription(description))

export const service = Command.make('service', {}, () => Effect.void).pipe(
  Command.withDescription('Service lifecycle and inspection commands'),
  Command.withSubcommands([
    list,
    info,
    status,
    lifecycleCommand('start', 'Start one service'),
    lifecycleCommand('stop', 'Stop one service'),
    lifecycleCommand('restart', 'Restart one service'),
    lifecycleCommand('enable', 'Enable service autostart'),
    lifecycleCommand('disable', 'Disable service autostart')
  ])
)
