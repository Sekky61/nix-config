import { Args, Command } from '@effect/cli'
import { Console, Effect } from 'effect'
import { findService } from '../lib/discovery'
import { runCommand } from '../lib/runtime'

const serviceArgument = Args.text({ name: 'service' })

export const open = Command.make('open', { serviceName: serviceArgument }, ({ serviceName }) =>
  Effect.gen(function* () {
    const service = yield* findService(serviceName)
    const url = service.urls[0]

    if (!url) {
      yield* Effect.fail(new Error(`Service ${service.name} has no known URL`))
    }

    const opener = process.platform === 'darwin' ? 'open' : 'xdg-open'
    yield* runCommand(opener, [url])
    yield* Console.log(`Opened ${url}`)
  })
).pipe(Command.withDescription('Open a service URL in the browser'))
