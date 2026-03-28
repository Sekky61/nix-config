import { spawn } from "node:child_process"
import { Effect } from "effect"

export class CommandExecutionError extends Error {
  readonly _tag = "CommandExecutionError"

  constructor(
    readonly command: string,
    readonly args: Array<string>,
    readonly exitCode: number,
    readonly stdout: string,
    readonly stderr: string
  ) {
    super(`Command failed: ${command} ${args.join(" ")}`)
  }
}

export const runCommand = (command: string, args: Array<string>) =>
  Effect.tryPromise({
    catch: (cause) => new Error(String(cause)),
    try: () =>
      new Promise<{ exitCode: number; stderr: string; stdout: string }>((resolve, reject) => {
        const child = spawn(command, args, {
          env: process.env,
          stdio: ["ignore", "pipe", "pipe"]
        })

        let stdout = ""
        let stderr = ""

        child.stdout.on("data", (chunk) => {
          stdout += String(chunk)
        })

        child.stderr.on("data", (chunk) => {
          stderr += String(chunk)
        })

        child.on("error", reject)
        child.on("close", (exitCode) => {
          resolve({ exitCode: exitCode ?? 1, stderr, stdout })
        })
      })
  }).pipe(
    Effect.flatMap(({ exitCode, stderr, stdout }) => {
      if (exitCode !== 0) {
        return Effect.fail(new CommandExecutionError(command, args, exitCode, stdout, stderr))
      }

      return Effect.succeed({ exitCode, stderr, stdout })
    })
  )

export const runCommandMaybe = (command: string, args: Array<string>) =>
  runCommand(command, args).pipe(
    Effect.map((result) => result.stdout.trim()),
    Effect.catchAll(() => Effect.succeed(null))
  )
