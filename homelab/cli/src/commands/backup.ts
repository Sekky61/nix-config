import { Args, Command } from '@effect/cli'
import { Console, Effect } from 'effect'
import path from 'node:path'
import { buildBackupPlan, executeBackupPlan } from '../lib/backup'
import { getHomelabPaths, selectServices } from '../lib/discovery'

const serviceArgument = Args.text({ name: 'service' }).pipe(Args.withDefault(null))

export const backup = Command.make('backup', { serviceName: serviceArgument }, ({ serviceName }) =>
  Effect.gen(function* () {
    const homelabPaths = getHomelabPaths()
    const services = yield* selectServices(serviceName)
    const plan = buildBackupPlan({ destinationDir: path.join(homelabPaths.homelabRoot, 'backups'), services })

    if (plan.entries.length === 0) {
      const scope = serviceName ? `service ${serviceName}` : 'selected services'
      yield* Effect.fail(new Error(`No backupable state found for ${scope}`))
    }

    const archivePath = yield* executeBackupPlan(plan)
    const activeServices = plan.services.filter((service) => service.activeState === 'active').map((service) => service.name)

    yield* Console.log(`Created ${archivePath}`)

    for (const service of plan.services) {
      const includedKinds = plan.entries
        .filter((entry) => entry.serviceName === service.name)
        .map((entry) => (entry.kind === 'data-dir' ? 'data' : 'env'))

      if (includedKinds.length > 0) {
        yield* Console.log(`- ${service.name}: ${includedKinds.join(', ')}`)
      }
    }

    if (activeServices.length > 0) {
      yield* Console.log(`Note: active services were not stopped before backup: ${activeServices.join(', ')}`)
    }
  })
).pipe(Command.withDescription('Create a tar.gz archive of homelab service state'))
