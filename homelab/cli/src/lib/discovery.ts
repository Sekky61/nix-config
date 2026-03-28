import { access, copyFile, mkdir, readdir, readFile, writeFile } from "node:fs/promises"
import os from "node:os"
import path from "node:path"
import { fileURLToPath } from "node:url"
import { Effect } from "effect"
import { runCommandMaybe } from "./runtime"

export type HealthLevel = "fail" | "ok" | "unknown" | "warn"

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
  readonly description: string
  readonly enabledState: string | null
  readonly envExampleFile: string | null
  readonly health: HealthLevel
  readonly liveContainerFile: string
  readonly liveEnvFile: string
  readonly name: string
  readonly notes: Array<string>
  readonly urls: Array<string>
}

export type HomelabNetwork = {
  readonly liveFile: string
  readonly name: string
  readonly sourceFile: string
}

const ignoredDirectories = new Set(["cli", "data", "docker", "networks", "scripts"])

export const getHomelabPaths = (): HomelabPaths => {
  const currentFile = fileURLToPath(import.meta.url)
  const cliRoot = path.resolve(path.dirname(currentFile), "..", "..")
  const homelabRoot = path.resolve(cliRoot, "..")
  const repoRoot = path.resolve(homelabRoot, "..")

  return {
    cliRoot,
    homelabRoot,
    liveQuadletDir: path.join(os.homedir(), ".config", "containers", "systemd"),
    repoRoot
  }
}

const fileExists = (targetPath: string) =>
  Effect.tryPromise({
    catch: () => false,
    try: async () => {
      await access(targetPath)
      return true
    }
  })

const readTextFile = (targetPath: string) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => readFile(targetPath, "utf8")
  })

const listDirectory = (targetPath: string) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () => readdir(targetPath, { withFileTypes: true })
  })

const parseDescription = (containerContents: string) => {
  const descriptionLine = containerContents
    .split("\n")
    .find((line) => line.startsWith("Description="))

  return descriptionLine?.slice("Description=".length) ?? "No description"
}

const parseUrls = (containerContents: string) =>
  containerContents
    .split("\n")
    .filter((line) => line.startsWith("PublishPort="))
    .map((line) => line.slice("PublishPort=".length).split(":")[0]?.trim())
    .filter((value): value is string => Boolean(value))
    .map((port) => `http://localhost:${port}`)

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
  if (!hasLiveContainerFile) {
    return "warn" satisfies HealthLevel
  }

  if (hasEnvExample && !hasEnvFile) {
    return "warn" satisfies HealthLevel
  }

  if (!hasDataDir) {
    return "warn" satisfies HealthLevel
  }

  if (activeState === "failed") {
    return "fail" satisfies HealthLevel
  }

  if (activeState === "active") {
    return "ok" satisfies HealthLevel
  }

  return "unknown" satisfies HealthLevel
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
    notes.push("run homelab apply")
  }

  if (hasEnvExample && !hasEnvFile) {
    notes.push("run homelab env init")
  }

  if (!hasDataDir) {
    notes.push("data dir missing")
  }

  if (activeState === "failed") {
    notes.push("service failed")
  }

  if (activeState === "inactive") {
    notes.push("service not running")
  }

  return notes
}

export const discoverNetworks = Effect.gen(function*() {
  const paths = getHomelabPaths()
  const networkDir = path.join(paths.homelabRoot, "networks")
  const entries = yield* listDirectory(networkDir)

  return entries
    .filter((entry) => entry.isFile() && entry.name.endsWith(".network"))
    .map((entry) => {
      const name = entry.name.replace(/\.network$/, "")
      return {
        liveFile: path.join(paths.liveQuadletDir, `${entry.name}`),
        name,
        sourceFile: path.join(networkDir, entry.name)
      } satisfies HomelabNetwork
    })
})

export const discoverServices = Effect.gen(function*() {
  const paths = getHomelabPaths()
  const entries = yield* listDirectory(paths.homelabRoot)

  const services = yield* Effect.all(
    entries
      .filter((entry) => entry.isDirectory() && !ignoredDirectories.has(entry.name))
      .map((entry) =>
        Effect.gen(function*() {
          const serviceRoot = path.join(paths.homelabRoot, entry.name)
          const containerFile = path.join(serviceRoot, `${entry.name}.container`)
          const envExampleFile = path.join(serviceRoot, `${entry.name}.env.example`)
          const liveContainerFile = path.join(paths.liveQuadletDir, `${entry.name}.container`)
          const liveEnvFile = path.join(paths.liveQuadletDir, `${entry.name}.env`)
          const dataDir = path.join(paths.homelabRoot, "data", entry.name)

          const hasContainerFile = yield* fileExists(containerFile)

          if (!hasContainerFile) {
            return null
          }

          const containerContents = yield* readTextFile(containerFile)
          const hasEnvExample = yield* fileExists(envExampleFile)
          const hasLiveContainerFile = yield* fileExists(liveContainerFile)
          const hasEnvFile = yield* fileExists(liveEnvFile)
          const hasDataDir = yield* fileExists(dataDir)
          const activeState = yield* runCommandMaybe("systemctl", [
            "--user",
            "show",
            "-p",
            "ActiveState",
            "--value",
            `${entry.name}.service`
          ])
          const enabledState = yield* runCommandMaybe("systemctl", [
            "--user",
            "show",
            "-p",
            "UnitFileState",
            "--value",
            `${entry.name}.service`
          ])

          return {
            activeState,
            containerFile,
            dataDir,
            description: parseDescription(containerContents),
            enabledState,
            envExampleFile: hasEnvExample ? envExampleFile : null,
            health: calculateHealth({ activeState, hasDataDir, hasEnvExample, hasEnvFile, hasLiveContainerFile }),
            liveContainerFile,
            liveEnvFile,
            name: entry.name,
            notes: buildNotes({ activeState, hasDataDir, hasEnvExample, hasEnvFile, hasLiveContainerFile }),
            urls: parseUrls(containerContents)
          } satisfies HomelabService
        })
      ),
    { concurrency: "unbounded" }
  )

  return services.filter((service): service is HomelabService => service !== null)
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
      const placeholder = `__${service.name.toUpperCase().replaceAll("-", "_")}_DATA_DIR__`
      return contents.replaceAll(placeholder, service.dataDir)
    }),
    Effect.flatMap((contents) =>
      Effect.tryPromise({
        catch: (cause) => new Error(String(cause)),
        try: () => writeFile(service.liveContainerFile, contents, "utf8")
      })
    )
  )

export const readEnvKeys = (targetPath: string) =>
  readTextFile(targetPath).pipe(
    Effect.map((contents) =>
      contents
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.length > 0 && !line.startsWith("#") && line.includes("="))
        .map((line) => line.split("=")[0]?.trim())
        .filter((key): key is string => Boolean(key))
        .sort()
    )
  )
