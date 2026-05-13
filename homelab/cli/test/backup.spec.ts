import { describe, expect, it } from 'vitest'
import { buildBackupPlan, buildDefaultBackupEntries } from '../src/lib/backup'
import type { HomelabService } from '../src/lib/discovery'

const makeService = (overrides: Partial<HomelabService> = {}): HomelabService => ({
  activeState: 'active',
  autostart: true,
  containerFile: '/repo/homelab/n8n/n8n.container',
  dataDir: '/repo/homelab/data/n8n',
  dependsOn: [],
  description: 'n8n workflow automation',
  enabledState: 'enabled',
  envExampleFile: '/repo/homelab/n8n/n8n.env.example',
  hasAutoupdate: true,
  hasDataDir: true,
  hasEnvExample: true,
  hasEnvFile: true,
  hasLiveContainerFile: true,
  health: 'ok',
  liveContainerFile: '/home/user/.config/containers/systemd/n8n.container',
  liveEnvFile: '/home/user/.config/containers/systemd/n8n.env',
  name: 'n8n',
  notes: [],
  ports: [5678],
  serviceRoot: '/repo/homelab/n8n',
  urls: ['http://localhost:5678'],
  ...overrides
})

describe('backup planning', () => {
  it('builds default entries for data and env state', () => {
    expect(buildDefaultBackupEntries(makeService())).toEqual([
      {
        archivePath: 'services/n8n/data',
        kind: 'data-dir',
        serviceName: 'n8n',
        sourcePath: '/repo/homelab/data/n8n'
      },
      {
        archivePath: 'services/n8n/env/n8n.env',
        kind: 'env-file',
        serviceName: 'n8n',
        sourcePath: '/home/user/.config/containers/systemd/n8n.env'
      }
    ])
  })

  it('creates a stable archive path and manifest-friendly service list', () => {
    expect(
      buildBackupPlan({
        destinationDir: '/repo/homelab/backups',
        now: new Date('2026-04-11T13:45:00Z'),
        services: [makeService()]
      })
    ).toMatchObject({
      archiveBaseName: 'n8n-backup-20260411T134500Z',
      archivePath: '/repo/homelab/backups/n8n-backup-20260411T134500Z.tar.gz',
      createdAt: '2026-04-11T13:45:00.000Z',
      services: [{ activeState: 'active', name: 'n8n' }]
    })
  })
})
