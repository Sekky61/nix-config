---
name: ags-astal
description: Write or update AGS and Astal code for Linux desktop shell components using TypeScript, JSX, GTK, and Astal libraries. Use this whenever the user mentions AGS, Astal, bars, launchers, popovers, shell widgets, `ags run`, even if they do not explicitly ask for a skill.
---

# AGS / Astal

Treat this skill as AGS v3-first unless the codebase clearly targets an older generation. AGS v3 uses `ags/*` imports, Gnim-style JSX, and Astal libraries through GI imports.

Start by inspecting the existing project before writing code. Match the project's GTK version, import style, file layout, and formatting setup.

Read bundled references selectively:

- Read `references/repo-patterns.md` when working in this repo.
- Read `references/ags-v3-guide.md` for AGS app structure, JSX, reactivity, theming, CLI, and migration gotchas.
- Read `references/astal-libraries.md` when the task touches system integrations such as battery, tray, media, audio, or network.
- If the task drops into lower-level `Gio`, `GLib`, `GObject`, or plain `gi://` platform work, also use the repo-local `gjs` skill.

## Defaults

- Prefer AGS v3 patterns over AGS v1/v2 patterns.
- Prefer GTK4 if the project already uses `ags/gtk4/app` or `gi://Gtk?version=4.0`.
- Prefer TypeScript and JSX unless the project clearly avoids them.
- Instantiate windows and heavyweight resources inside `app.start({ main() { ... } })` or component scope, not at module top level.
- Prefer Astal libraries and GObject signals over polling or ad hoc shell commands.
- Prefer `class` plus stylesheet rules over inline `css`.
- Prefer official AGS/Astal docs over memory when an API detail is unclear.

## Workflow

1. Inspect the local project.
2. Identify AGS generation and GTK version from imports and file layout.
3. If TypeScript types are missing or stale, run `ags types -d . -u` in the project root.
4. Decide whether the task is:
   - pure UI/layout
   - reactive local state
   - GObject property binding
   - Astal-backed system integration
   - migration from older AGS/Astal code
5. Implement the smallest correct component structure first, then wire state, then style.
6. Keep styling in `css`/`scss` files unless a one-off widget property genuinely needs dynamic inline CSS.
7. If the widget should be CLI-addressable, register the window properly and give it a stable `name`.
8. Unless the user asked for builds/tests, finish with a readback and concise usage notes rather than running the whole stack.

## Project detection

Check these signals before coding:

- `import app from 'ags/gtk4/app'`: AGS v3 + GTK4.
- `import app from 'ags/gtk3/app'`: AGS v3 + GTK3.
- `import ... from 'astal/...` or `Variable` / `bind` / `App.config`: older patterns, likely migration work.
- `gi://AstalBattery`, `gi://AstalTray`, `gi://AstalMpris`, etc.: Astal library usage through GI.

If you see old APIs, convert them instead of extending them in place with more legacy patterns.

## Core coding rules

### App structure

- The entry point is `app.start(...)`.
- Create windows in `main()`.
- In GTK4, windows are not visible by default, so explicitly set `visible`.

Minimal skeleton:

```tsx
import app from 'ags/gtk4/app';
import { Astal } from 'ags/gtk4';

app.start({
  main() {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

    return (
      <window visible anchor={TOP | LEFT | RIGHT}>
        <box />
      </window>
    );
  },
});
```

### JSX and widgets

- Lowercase tags like `<box />` are builtin intrinsic widgets.
- Capitalized tags like `<MyWidget />` are custom components.
- Use a single props object for custom components.
- If the user wants to avoid JSX, that is allowed, but JSX is the default and recommended path.

### Reactivity

Use the AGS v3 signal primitives:

- `createState` for writable local reactive state
- `createBinding` for GObject properties
- `createComputed` for derived state
- `<With>` for nullable/dynamic single-child rendering
- `<For>` for dynamic list rendering

Preferred examples:

```tsx
import { createState, createBinding, createComputed } from 'ags';

const [count, setCount] = createState(0);
const label = createComputed(() => count().toString());
```

```tsx
const percentage = createBinding(battery, 'percentage')(
  (p) => `${Math.round(p * 100)}%`,
);
```

Prefer setting `visible` on existing widgets over using `<With>` unless you need to unpack nullable objects or rebuild the subtree.

Wrap `<With>` and `<For>` in a container when ordering matters.

### Astal libraries

- Import Astal libraries through GI imports such as `import Battery from 'gi://AstalBattery'`.
- Prefer library APIs over shelling out when the capability exists in Astal.
- Use `get_default()` for singleton-style libraries when available.
- Bind library object properties with `createBinding(...)`.

### Processes and polling

- Avoid polling when an event-driven library or signal exists.
- `createPoll` is acceptable for clocks, lightweight derived state, or fallback integrations.
- `exec` and `execAsync` do not run inside a shell by default.
- Do not rely on shell expansion like `$HOME` unless you explicitly invoke a shell.

### Styling

- Import `css` or `scss` into the entrypoint and pass it through `app.start({ css: ... })`.
- Prefer classes and stylesheet selectors over widget `css` props.
- Remember GTK CSS is not browser CSS; only use supported GTK features.
- Use the GTK inspector when selector or hierarchy behavior is unclear.

### Windows and CLI

- To toggle a window from `ags toggle`, register it with the application.
- Either call `app.add_window(self)` or use `application={app}`.
- If you use `application={app}`, set `name` before `application`.
- When monitor identity matters, prefer `gdkmonitor` over numeric `monitor`.

## Migration rules

When updating older code, convert to these AGS v3 equivalents:

- `astal/*` frontend imports -> `ags/*`
- `Variable` -> `createState` or other Accessor creators
- `bind(...)` -> `createBinding(...)`
- `setup` prop -> `$`
- `className` prop -> `class`
- `astalify(...)` wrappers -> direct JSX / `Gtk.*` widgets where possible
- AGS v1 `App.config(...)` -> `app.start(...)`

Do not try to preserve AGS v1 structure verbatim. The docs explicitly say AGS v1 projects generally need a ground-up rewrite.

## Output expectations

When implementing or editing AGS/Astal code:

- Keep imports explicit and consistent.
- Keep reactive values close to the widget using them.
- Split into components when a function is doing more than one UI concern.
- Put styling in a stylesheet file if the project already has one.
- Explain any fallback to shell commands when an Astal library was not used.

## Repo note

In this repo, the AGS v3 example lives under `modules/gui-packages/ags/config-v3/`. Use `references/repo-patterns.md` before editing there so your changes match the existing local patterns.
