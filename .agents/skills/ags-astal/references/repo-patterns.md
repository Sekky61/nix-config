# Repo Patterns For `modules/gui-packages/ags/config-v3`

Use this file when editing the AGS config in this repo.

## Current local layout

- `modules/gui-packages/ags/config-v3/app.tsx`
- `modules/gui-packages/ags/config-v3/bar.tsx`
- `modules/gui-packages/ags/config-v3/style.scss`
- `modules/gui-packages/ags/config-v3/tsconfig.json`
- `modules/gui-packages/ags/config-v3/package.json`
- `modules/gui-packages/ags/config-v3/prettier.config.mjs`
- `modules/gui-packages/ags/config-v3/readme.md`

## Local conventions already present

- GTK4 app entrypoint: `import app from 'ags/gtk4/app'`
- JSX and AGS helpers imported from `ags`
- Astal integrations imported via GI modules such as:
  - `gi://AstalBattery`
  - `gi://AstalMpris`
  - `gi://AstalNetwork`
  - `gi://AstalPowerProfiles`
  - `gi://AstalTray`
  - `gi://AstalWp`
  - `gi://AstalApps`
- Local formatting is Prettier-based in this directory

## Patterns worth copying

### App entry

- `app.tsx` imports `style.scss` and passes it via `css: style`.
- The app sets `gtkTheme: 'Adwaita'`.
- Monitors are derived reactively with `createBinding(app, 'monitors')`.
- Windows are rendered with `<For each={monitors}>`.
- Each window gets a `gdkmonitor` object rather than a numeric monitor id.

### Components

- `bar.tsx` uses small widget functions like `Mpris`, `Tray`, `Wireless`, `AudioOutput`, `Battery`, and `Clock`.
- Properties from Astal objects are consumed with `createBinding(...)`.
- Dynamic child trees use `<For>` and `<With>`.
- Shell commands are a fallback, not the first choice. The current Wi-Fi connect helper uses `execAsync(...)` only because that capability is not fully covered there.

### Styling

- `style.scss` uses GTK theme variables and keeps styling centralized.
- Styling is modest and GTK-aware rather than web-like.

## Local commands

From `modules/gui-packages/ags/config-v3/`:

- Generate types: `ags types -d . -u`
- Install formatter dependency: `npm install`
- Format: `npm run format`
- Check formatting: `npm run format:check`

## Editing guidance

- Keep TypeScript import style consistent with the current files.
- Favor adding or extending small component functions over building one giant `bar.tsx`.
- When touching monitor-aware windows, keep using `gdkmonitor`.
- Keep comments sparse and only for non-obvious constraints.
