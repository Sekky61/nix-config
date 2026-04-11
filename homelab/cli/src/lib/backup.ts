import { cp, mkdtemp, rm, writeFile } from 'node:fs/promises'
import os from 'node:os'
import path from 'node:path'
import { Effect } from 'effect'
import { ensureDirectory, type HomelabService } from './discovery'
import { runCommand } from './runtime'

export type BackupEntryKind = 'data-dir' | 'env-file'

export type BackupEntry = {
  readonly archivePath: string
  readonly kind: BackupEntryKind
  readonly serviceName: string
  readonly sourcePath: string
}

export type BackupPlan = {
  readonly archiveBaseName: string
  readonly archivePath: string
  readonly createdAt: string
  readonly entries: Array<BackupEntry>
  readonly services: Array<{
    readonly activeState: string | null
    readonly name: string
  }>
}

const formatBackupTimestamp = (date: Date) => date.toISOString().replace(/[-:]/g, '').replace(/\.\d+Z$/, 'Z')

export const buildDefaultBackupEntries = (service: HomelabService): Array<BackupEntry> => {
  const entries: Array<BackupEntry> = []

  if (service.hasDataDir) {
    entries.push({
      archivePath: path.join('services', service.name, 'data'),
      kind: 'data-dir',
      serviceName: service.name,
      sourcePath: service.dataDir
    })
  }

  if (service.hasEnvFile) {
    entries.push({
      archivePath: path.join('services', service.name, 'env', path.basename(service.liveEnvFile)),
      kind: 'env-file',
      serviceName: service.name,
      sourcePath: service.liveEnvFile
    })
  }

  return entries
}

export const buildBackupPlan = ({
  destinationDir,
  now = new Date(),
  services
}: {
  readonly destinationDir: string
  readonly now?: Date
  readonly services: Array<HomelabService>
}): BackupPlan => {
  const timestamp = formatBackupTimestamp(now)
  const archiveBaseName = `${services.length === 1 ? services[0]!.name : 'homelab'}-backup-${timestamp}`

  return {
    archiveBaseName,
    archivePath: path.join(destinationDir, `${archiveBaseName}.tar.gz`),
    createdAt: now.toISOString(),
    entries: services.flatMap(buildDefaultBackupEntries),
    services: services.map((service) => ({ activeState: service.activeState, name: service.name }))
  }
}

const createTemporaryDirectory = () =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => mkdtemp(path.join(os.tmpdir(), 'homelab-backup-'))
  })

const removeTemporaryDirectory = (targetPath: string) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => rm(targetPath, { force: true, recursive: true })
  }).pipe(Effect.catchAll(() => Effect.void))

const copyEntryToArchiveRoot = ({ archiveRoot, entry }: { readonly archiveRoot: string; readonly entry: BackupEntry }) =>
  Effect.gen(function* () {
    const destinationPath = path.join(archiveRoot, entry.archivePath)

    yield* ensureDirectory(path.dirname(destinationPath))

    yield* Effect.tryPromise({
      catch: (cause) => new Error(String(cause)),
      try: () => cp(entry.sourcePath, destinationPath, { recursive: entry.kind === 'data-dir' })
    })
  })

const writeBackupManifest = ({ archiveRoot, plan }: { readonly archiveRoot: string; readonly plan: BackupPlan }) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () =>
      writeFile(
        path.join(archiveRoot, 'manifest.json'),
        JSON.stringify(
          {
            createdAt: plan.createdAt,
            entries: plan.entries.map((entry) => ({
              archivePath: entry.archivePath,
              kind: entry.kind,
              serviceName: entry.serviceName,
              sourcePath: entry.sourcePath
            })),
            services: plan.services,
            version: 1
          },
          null,
          2
        ) + '\n',
        'utf8'
      )
  })

export const executeBackupPlan = (plan: BackupPlan) => {
  if (plan.entries.length === 0) {
    return Effect.fail(new Error('No backupable state found for the selected services'))
  }

  return Effect.acquireUseRelease(
    createTemporaryDirectory(),
    (stagingRoot) =>
      Effect.gen(function* () {
        const archiveRoot = path.join(stagingRoot, plan.archiveBaseName)

        yield* ensureDirectory(path.dirname(plan.archivePath))
        yield* ensureDirectory(archiveRoot)

        for (const entry of plan.entries) {
          yield* copyEntryToArchiveRoot({ archiveRoot, entry })
        }

        yield* writeBackupManifest({ archiveRoot, plan })
        yield* runCommand('tar', ['-C', stagingRoot, '-czf', plan.archivePath, plan.archiveBaseName])

        return plan.archivePath
      }),
    removeTemporaryDirectory
  )
}
