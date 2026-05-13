import { describe, expect, it } from "vitest"
import { buildNotes, calculateHealth, setQuadletAutostart } from "../src/lib/discovery"

describe("status health model", () => {
  it("returns ok for an active and fully configured service", () => {
    expect(
      calculateHealth({
        activeState: "active",
        hasDataDir: true,
        hasEnvExample: true,
        hasEnvFile: true,
        hasLiveContainerFile: true
      })
    ).toBe("ok")
  })

  it("returns warn when the live env file is missing", () => {
    expect(
      calculateHealth({
        activeState: "inactive",
        hasDataDir: true,
        hasEnvExample: true,
        hasEnvFile: false,
        hasLiveContainerFile: true
      })
    ).toBe("warn")
  })

  it("builds actionable notes for missing setup and failed runtime", () => {
    expect(
      buildNotes({
        activeState: "failed",
        hasDataDir: false,
        hasEnvExample: true,
        hasEnvFile: false,
        hasLiveContainerFile: false
      })
    ).toEqual(["run homelab apply", "run homelab env init", "data dir missing", "service failed"])
  })

  it("removes Quadlet default target autostart", () => {
    expect(
      setQuadletAutostart(
        `[Unit]
Description=Example

[Container]
Image=example:latest

[Service]
Restart=on-failure

[Install]
WantedBy=default.target
`,
        false
      )
    ).toBe(`[Unit]
Description=Example

[Container]
Image=example:latest

[Service]
Restart=on-failure
`)
  })

  it("adds Quadlet default target autostart", () => {
    expect(
      setQuadletAutostart(
        `[Unit]
Description=Example
`,
        true
      )
    ).toBe(`[Unit]
Description=Example

[Install]
WantedBy=default.target
`)
  })
})
