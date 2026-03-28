import { access, copyFile, mkdir, readdir, readFile, writeFile } from 'node:fs/promises'
import os from 'node:os'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { Effect } from 'effect'
import { runCommandMaybe } from './runtime'

export type HealthLevel = 'fail' | 'ok' | 'unknown' | 'warn'

export type HomelabPaths = {
  readonly cliRoot: string
  readonly homelabRoot: string
  readonly liveQuadletDir: string
  readonly repoRoot: string
}

export type HomelabService = {
  readonly activeState: string | null
  readonly containerFile: string
  readonly dataDir: string
  readonly dependsOn: Array<string>
  readonly description: string
  readonly enabledState: string | null
  readonly envExampleFile: string | null
  readonly hasAutoupdate: boolean
  readonly hasDataDir: boolean
  readonly hasEnvExample: boolean
  readonly hasEnvFile: boolean
  readonly hasLiveContainerFile: boolean
  readonly health: HealthLevel
  readonly liveContainerFile: string
  readonly liveEnvFile: string
  readonly name: string
  readonly notes: Array<string>
  readonly ports: Array<number>
  readonly serviceRoot: string
  readonly urls: Array<string>
}

export type HomelabNetwork = {
  readonly hasLiveFile: boolean
  readonly liveFile: string
  readonly name: string
  readonly sourceFile: string
}

const ignoredDirectories = new Set(['cli', 'data', 'docker', 'networks', 'scripts'])

export const getHomelabPaths = (): HomelabPaths => {
  const currentFile = fileURLToPath(import.meta.url)
  const cliRoot = path.resolve(path.dirname(currentFile), '..', '..')
  const homelabRoot = path.resolve(cliRoot, '..')
  const repoRoot = path.resolve(homelabRoot, '..')

  return {
    cliRoot,
    homelabRoot,
    liveQuadletDir: path.join(os.homedir(), '.config', 'containers', 'systemd'),
    repoRoot
  }
}

const fileExists = (targetPath: string) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: async () => {
      await access(targetPath)
      return true
    }
  }).pipe(Effect.catchAll(() => Effect.succeed(false)))

const readTextFile = (targetPath: string) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => readFile(targetPath, 'utf8')
  })

const listDirectory = (targetPath: string) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => readdir(targetPath, { withFileTypes: true })
  })

const getFieldValues = (contents: string, fieldName: string) =>
  contents
    .split('\n')
    .filter((line) => line.startsWith(`${fieldName}=`))
    .map((line) => line.slice(fieldName.length + 1).trim())
    .filter((value) => value.length > 0)

const parseDescription = (containerContents: string) => getFieldValues(containerContents, 'Description')[0] ?? 'No description'

const parsePorts = (containerContents: string) =>
  getFieldValues(containerContents, 'PublishPort')
    .map((value) => value.split(':')[0]?.trim())
    .filter((value): value is string => Boolean(value))
    .map((value) => Number.parseInt(value, 10))
    .filter((value) => Number.isFinite(value))

const parseUrls = (containerContents: string) => parsePorts(containerContents).map((port) => `http://localhost:${port}`)

const parseDependencies = (containerContents: string) =>
  [...getFieldValues(containerContents, 'Wants'), ...getFieldValues(containerContents, 'After')]
    .filter((value) => value.endsWith('.service'))
    .map((value) => value.replace(/\.service$/, ''))
    .filter((value) => value !== 'network-online.target')
    .filter((value, index, values) => values.indexOf(value) === index)

const parseHasAutoupdate = (containerContents: string) =>
  getFieldValues(containerContents, 'AutoUpdate').some((value) => value !== 'none')

export const calculateHealth = ({
  activeState,
  hasDataDir,
  hasEnvExample,
  hasEnvFile,
  hasLiveContainerFile
}: {
  readonly activeState: string | null
  readonly hasDataDir: boolean
  readonly hasEnvExample: boolean
  readonly hasEnvFile: boolean
  readonly hasLiveContainerFile: boolean
}) => {
  if (activeState === 'failed') {
    return 'fail' satisfies HealthLevel
  }

  if (!hasLiveContainerFile) {
    return 'warn' satisfies HealthLevel
  }

  if (hasEnvExample && !hasEnvFile) {
    return 'warn' satisfies HealthLevel
  }

  if (!hasDataDir) {
    return 'warn' satisfies HealthLevel
  }

  if (activeState === 'active') {
    return 'ok' satisfies HealthLevel
  }

  return 'unknown' satisfies HealthLevel
}

export const buildNotes = ({
  activeState,
  hasDataDir,
  hasEnvExample,
  hasEnvFile,
  hasLiveContainerFile
}: {
  readonly activeState: string | null
  readonly hasDataDir: boolean
  readonly hasEnvExample: boolean
  readonly hasEnvFile: boolean
  readonly hasLiveContainerFile: boolean
}) => {
  const notes: Array<string> = []

  if (!hasLiveContainerFile) {
    notes.push('run homelab apply')
  }

  if (hasEnvExample && !hasEnvFile) {
    notes.push('run homelab env init')
  }

  if (!hasDataDir) {
    notes.push('data dir missing')
  }

  if (activeState === 'failed') {
    notes.push('service failed')
  }

  if (activeState === 'inactive') {
    notes.push('service not running')
  }

  return notes
}

export const discoverNetworks = Effect.gen(function* () {
  const paths = getHomelabPaths()
  const networkDir = path.join(paths.homelabRoot, 'networks')
  const entries = yield* listDirectory(networkDir)

  const networks = yield* Effect.all(
    entries
      .filter((entry) => entry.isFile() && entry.name.endsWith('.network'))
      .map((entry) =>
        Effect.gen(function* () {
          const liveFile = path.join(paths.liveQuadletDir, entry.name)

          return {
            hasLiveFile: yield* fileExists(liveFile),
            liveFile,
            name: entry.name.replace(/\.network$/, ''),
            sourceFile: path.join(networkDir, entry.name)
          } satisfies HomelabNetwork
        })
      ),
    { concurrency: 'unbounded' }
  )

  return networks.sort((left, right) => left.name.localeCompare(right.name))
})

export const discoverServices = Effect.gen(function* () {
  const paths = getHomelabPaths()
  const entries = yield* listDirectory(paths.homelabRoot)

  const services = yield* Effect.all(
    entries
      .filter((entry) => entry.isDirectory() && !ignoredDirectories.has(entry.name))
      .map((entry) =>
        Effect.gen(function* () {
          const serviceRoot = path.join(paths.homelabRoot, entry.name)
          const containerFile = path.join(serviceRoot, `${entry.name}.container`)
          const envExampleFile = path.join(serviceRoot, `${entry.name}.env.example`)
          const liveContainerFile = path.join(paths.liveQuadletDir, `${entry.name}.container`)
          const liveEnvFile = path.join(paths.liveQuadletDir, `${entry.name}.env`)
          const dataDir = path.join(paths.homelabRoot, 'data', entry.name)

          const hasContainerFile = yield* fileExists(containerFile)

          if (!hasContainerFile) {
            return null
          }

          const containerContents = yield* readTextFile(containerFile)
          const hasEnvExample = yield* fileExists(envExampleFile)
          const hasLiveContainerFile = yield* fileExists(liveContainerFile)
          const hasEnvFile = yield* fileExists(liveEnvFile)
          const hasDataDir = yield* fileExists(dataDir)
          const activeState = yield* runCommandMaybe('systemctl', [
            '--user',
            'show',
            '-p',
            'ActiveState',
            '--value',
            `${entry.name}.service`
          ])
          const enabledState = yield* runCommandMaybe('systemctl', [
            '--user',
            'show',
            '-p',
            'UnitFileState',
            '--value',
            `${entry.name}.service`
          ])

          return {
            activeState,
            containerFile,
            dataDir,
            dependsOn: parseDependencies(containerContents),
            description: parseDescription(containerContents),
            enabledState,
            envExampleFile: hasEnvExample ? envExampleFile : null,
            hasAutoupdate: parseHasAutoupdate(containerContents),
            hasDataDir,
            hasEnvExample,
            hasEnvFile,
            hasLiveContainerFile,
            health: calculateHealth({ activeState, hasDataDir, hasEnvExample, hasEnvFile, hasLiveContainerFile }),
            liveContainerFile,
            liveEnvFile,
            name: entry.name,
            notes: buildNotes({ activeState, hasDataDir, hasEnvExample, hasEnvFile, hasLiveContainerFile }),
            ports: parsePorts(containerContents),
            serviceRoot,
            urls: parseUrls(containerContents)
          } satisfies HomelabService
        })
      ),
    { concurrency: 'unbounded' }
  )

  return services
    .filter((service): service is HomelabService => service !== null)
    .sort((left, right) => left.name.localeCompare(right.name))
})

export const findService = (serviceName: string) =>
  discoverServices.pipe(
    Effect.flatMap((services) => {
      const service = services.find((candidate) => candidate.name === serviceName)
      return service ? Effect.succeed(service) : Effect.fail(new Error(`Unknown service: ${serviceName}`))
    })
  )

export const ensureDirectory = (targetPath: string) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => mkdir(targetPath, { recursive: true })
  })

export const copyFileTo = ({ destination, source }: { readonly destination: string; readonly source: string }) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => copyFile(source, destination)
  })

export const copyIfMissing = ({ destination, source }: { readonly destination: string; readonly source: string }) =>
  fileExists(destination).pipe(
    Effect.flatMap((exists) =>
      exists
        ? Effect.succeed(false)
        : Effect.tryPromise({
            catch: (cause) => new Error(String(cause)),
            try: () => copyFile(source, destination).then(() => true)
          })
    )
  )

export const renderServiceContainer = (service: HomelabService) =>
  readTextFile(service.containerFile).pipe(
    Effect.map((contents) => {
      const placeholder = `__${service.name.toUpperCase().replaceAll('-', '_')}_DATA_DIR__`
      return contents.replaceAll(placeholder, service.dataDir)
    }),
    Effect.flatMap((contents) =>
      Effect.tryPromise({
        catch: (cause) => new Error(String(cause)),
        try: () => writeFile(service.liveContainerFile, contents, 'utf8')
      })
    )
  )

export const readEnvKeys = (targetPath: string) =>
  readTextFile(targetPath).pipe(
    Effect.map((contents) =>
      contents
        .split('\n')
        .map((line) => line.trim())
        .filter((line) => line.length > 0 && !line.startsWith('#') && line.includes('='))
        .map((line) => line.split('=')[0]?.trim())
        .filter((key): key is string => Boolean(key))
        .sort()
    )
  )

export const selectServices = (serviceName: string | null) =>
  discoverServices.pipe(
    Effect.flatMap((services) => {
      if (!serviceName) {
        return Effect.succeed(services)
      }

      const selectedServices = services.filter((service) => service.name === serviceName)
      return selectedServices.length > 0
        ? Effect.succeed(selectedServices)
        : Effect.fail(new Error(`Unknown service: ${serviceName}`))
    })
  )
