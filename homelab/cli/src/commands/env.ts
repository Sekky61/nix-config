import { Args, Command } from '@effect/cli'
import { Console, Effect } from 'effect'
import { copyIfMissing, discoverServices, findService, readEnvKeys } from '../lib/discovery'
import { runCommandInherit } from '../lib/runtime'

const serviceArgument = Args.text({ name: 'service' })

const list = Command.make('list', {}, () =>
  Effect.gen(function* () {
    const services = yield* discoverServices

    for (const service of services.filter((candidate) => candidate.hasEnvExample)) {
      yield* Console.log(`${service.name}: ${service.liveEnvFile}`)
    }
  })
).pipe(Command.withDescription('List service env files'))

const pathCommand = Command.make('path', { serviceName: serviceArgument }, ({ serviceName }) =>
  Effect.gen(function* () {
    const service = yield* findService(serviceName)
    yield* Console.log(service.liveEnvFile)
  })
).pipe(Command.withDescription('Print the live env path for a service'))

const init = Command.make('init', { serviceName: serviceArgument }, ({ serviceName }) =>
  Effect.gen(function* () {
    const service = yield* findService(serviceName)

    if (!service.envExampleFile) {
      yield* Effect.fail(new Error(`Service ${service.name} has no env example file`))
    }

    const envExampleFile = service.envExampleFile!

    const created = yield* copyIfMissing({
      destination: service.liveEnvFile,
      source: envExampleFile
    })

    yield* Console.log(created ? `Created ${service.liveEnvFile}` : `${service.liveEnvFile} already exists`)
  })
).pipe(Command.withDescription('Create the live env file from the example if missing'))

const edit = Command.make('edit', { serviceName: serviceArgument }, ({ serviceName }) =>
  Effect.gen(function* () {
    const service = yield* findService(serviceName)
    const editor = process.env.EDITOR ?? 'vi'
    yield* runCommandInherit(editor, [service.liveEnvFile])
  })
).pipe(Command.withDescription('Open the live env file in $EDITOR'))

const diff = Command.make('diff', { serviceName: serviceArgument }, ({ serviceName }) =>
  Effect.gen(function* () {
    const service = yield* findService(serviceName)

    if (!service.envExampleFile) {
      yield* Effect.fail(new Error(`Service ${service.name} has no env example file`))
    }

    const envExampleFile = service.envExampleFile!

    const exampleKeys = yield* readEnvKeys(envExampleFile)
    const liveKeys = service.hasEnvFile ? yield* readEnvKeys(service.liveEnvFile) : []
    const missingInLive = exampleKeys.filter((key) => !liveKeys.includes(key))
    const extraInLive = liveKeys.filter((key) => !exampleKeys.includes(key))

    yield* Console.log(`example: ${exampleKeys.join(', ') || '(none)'}`)
    yield* Console.log(`live: ${liveKeys.join(', ') || '(none)'}`)
    yield* Console.log(`missing in live: ${missingInLive.join(', ') || '(none)'}`)
    yield* Console.log(`extra in live: ${extraInLive.join(', ') || '(none)'}`)
  })
).pipe(Command.withDescription('Compare env keys between example and live env files'))

export const env = Command.make('env', {}, () => Effect.void).pipe(
  Command.withDescription('Manage service env files'),
  Command.withSubcommands([list, pathCommand, init, edit, diff])
)
