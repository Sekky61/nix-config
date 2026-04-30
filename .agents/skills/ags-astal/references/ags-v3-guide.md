# AGS v3 Guide Notes

This file condenses the AGS docs into implementation guidance for TypeScript + JSX work.

## What AGS is

- AGS is the CLI and frontend workflow layer for writing desktop shell components in JavaScript or TypeScript.
- GJS is the runtime.
- Gnim powers the JSX/component model and is reexported through `ags`.
- Astal libraries provide most of the backend integrations.

Practical import note:

- if Gnim docs show `import { fetch, URL } from 'gnim/fetch'`, the AGS equivalent is `import { fetch, URL } from 'ags/fetch'`
- similarly, `gnim/gobject` becomes `ags/gobject`
- and `gnim`-level concepts such as JSX helpers or decorators often exist through AGS reexports in AGS projects

## Setup commands

- Initialize a project: `ags init -d /path/to/project`
- Generate TS types: `ags types -u -d /path/to/project/root`
- Run an entry file: `ags run ./app.tsx`

## Entry point

- The application entry point is `app.start({ ... })`.
- Instantiate widgets in `main()`.
- Avoid top-level instances because later executions may run in client mode rather than main mode.

## Widgets and JSX

- Lowercase tags are builtin intrinsic widgets such as `<box />`, `<button />`, and `<window />`.
- Capitalized tags are custom components.
- In GTK4, `<window>` is not visible by default. Set `visible`.
- JSX is preferred, but `jsx(...)` without JSX is still possible when needed.
- A JSX expression is typed as base `GObject.Object`, not the concrete widget subtype. If a property needs the real subtype, use `jsx(...)` directly or type assert the JSX result.
- There are no intrinsic elements by default in raw Gnim; prefer real function/class components over inventing custom lowercase intrinsics.

Important `jsx(...)` typing case:

```tsx
import { jsx } from 'ags';

const menuButton = new Gtk.MenuButton();
menuButton.popover = jsx(Gtk.Popover, {});
```

## Reactivity

AGS v3 reactive primitives:

- `createState(initial)` for writable local state
- `createBinding(object, 'prop')` for GObject property bindings
- `createComputed(() => ...)` for derived values
- `<With value={...}>` for nullable / dynamic single-node rendering
- `<For each={...}>` for dynamic lists

Useful shorthand:

- `createComputed(() => count().toString())`
- `count((c) => c.toString())`

Use `visible` instead of `<With>` when the widget can stay mounted.

For nested nullable objects, either:

- use `<With>` to unpack the object and bind inside it
- or use `createBinding(object, 'nested', 'value')` to bind through a property path

Wrap `<For>` or `<With>` in a container when ordering matters, because re-rendered children are appended rather than position-stabilized.

## Gnim/AGS utilities beyond process and time

- GJS does not provide the usual web `fetch` globally in the way web runtimes do.
- Use the AGS fetch module when you want fetch-like HTTP helpers in an AGS app.
- In AGS code, import it as:

```ts
import { fetch, URL } from 'ags/fetch';
```

## Processes and time

- `createPoll(...)` only runs while it has subscribers.
- Prefer signals and library-backed state over polling.
- `exec` and `execAsync` are not shell commands unless you explicitly run a shell.
- Use `GLib.getenv(...)` rather than `exec('echo $HOME')`.
- If all you want is plain stdout or stderr output for debugging, prefer `print(...)` / `printerr(...)` over `console` logging.

## Styling

- Import `css` or `scss` into the entrypoint and pass it to `app.start({ css })`.
- Prefer class-based styling and stylesheets over inline widget `css`.
- Widget `css` does not cascade to children.
- GTK CSS is not web CSS; use GTK CSS docs to verify support.
- GTK styling targets CSS nodes, not HTML elements. Check the widget docs when a selector does not behave as expected.
- Widget names can be used like IDs with `#name`; style classes use `.class`.
- GTK-specific selector behavior exists for states like `:focus-within` and `:focus-visible`; do not assume exact browser semantics.
- GTK 4.16+ supports CSS custom properties and `var()`. Older `@define-color` syntax is deprecated.
- GTK 4.20+ supports media queries such as `prefers-color-scheme`, `prefers-contrast`, and `prefers-reduced-motion`.
- Common web-like features such as transitions, animations, `box-shadow`, and `border-radius` are supported, but property coverage is selective.
- Inspect with `ags inspect` when layout or selector behavior is unclear.

## GObject and DBus decorators

Gnim's decorator helpers are relevant in AGS because AGS reexports them.

- `gnim/gobject` maps to `ags/gobject`
- `gnim/dbus` concepts should be treated as compatible mental models when writing typed DBus/GObject helpers alongside AGS
- these decorators wrap `GObject.registerClass(...)` and reduce boilerplate for properties, signals, and typed DBus interfaces

TypeScript constraints from Gnim docs:

- keep `target` at `ES2020` or lower
- keep `experimentalDecorators` set to `false`

For GObject subclasses, decorators can define properties and signals declaratively. For DBus classes, the DBus properties and signals are also surfaced as GObject properties and signals through the service base class.

## CLI integration

- Use `requestHandler(argv, response)` to support `ags request ...`.
- The response callback can only be called once.
- Register windows using `app.add_window(...)` or `application={app}`.
- If you use `application={app}`, set `name` first.
- `ags toggle WindowName` depends on proper window registration.
- For global keybindings, use compositor-level keybinds and route into AGS through requests; focused windows only can handle regular key events.

## Monitor handling

- Numeric `monitor` IDs are GDK-mapped and may not match the compositor.
- Prefer `gdkmonitor={monitor}` when you are deriving windows from `app.get_monitors()` or monitor bindings.
- `<For each={createBinding(app, 'monitors')}>` is the preferred per-monitor pattern for auto-creating and auto-destroying windows.

## GTK4-specific FAQ rules

- For regular floating windows, use `Gtk.Window` rather than `Astal.Window`.
- For GTK4 popups, use `Gtk.Popover`.
- For width and height limiting in GTK4, prefer real layout solutions such as `Adw.Clamp` instead of trying to force browser-style max sizing everywhere.
- Some GI list-like properties do not bind cleanly through GJS and can trigger `Can't convert non-null pointer to JS value`; prefer explicit getter methods such as `get_notifications()` when available.

## JSX `$` setup notes

- The `$` setup function runs after properties are set, signals are connected, and children are appended, but before `jsx(...)` returns.
- This makes `$` the right place to grab imperative references or initialize relationships between widgets already in the subtree.
- For function components, use `FCProps<WidgetType, Props>` if you want TypeScript to understand the `$` prop on that component.

Good uses of `$`:

- storing a widget reference in local scope
- wiring one widget to another after both exist, for example `searchbar.set_key_capture_widget(win)`
- one-off imperative initialization that does not belong in the render expression itself

## Migration map

### v2 to v3

- `astal` frontend namespace was dropped in favor of `ags`.
- `astalify` is gone; JSX and direct `Gtk.*` widgets replace it.
- `setup` becomes `$`.
- `className` becomes `class`.
- `Variable` becomes Accessor-based state such as `createState`.
- `bind(...)` becomes `createBinding(...)`.

### v1 to v3

- Treat AGS v1 code as rewrite territory.
- `App.config(...)` becomes `app.start(...)`.
- Old global `Widget`, `App`, `Service`, `Utils`, `Variable` usage should be replaced with explicit imports.
- Old services become Astal or other GI-backed libraries plus explicit bindings.

## Concrete reminders from the FAQ

- Avoid JSX only if the project clearly wants that; JSX is optional, not required.
- Do not use shell assumptions inside `exec(...)`.
- Prefer `gdkmonitor` over numeric `monitor`.
- Prefer `<For>` for monitor fan-out.
- Prefer `Gtk.Popover` for GTK4 popups.
- Prefer explicit getters for troublesome GI list properties.

## Source pages

- AGS home: https://aylur.github.io/ags/
- Quick Start: https://aylur.github.io/ags/guide/quick-start.html
- First Widgets: https://aylur.github.io/ags/guide/first-widgets.html
- Theming: https://aylur.github.io/ags/guide/theming.html
- App and CLI: https://aylur.github.io/ags/guide/app-cli.html
- Utilities: https://aylur.github.io/ags/guide/utilities.html
- Resources: https://aylur.github.io/ags/guide/resources.html
- FAQ: https://aylur.github.io/ags/guide/faq.html
- Migration Guide: https://aylur.github.io/ags/guide/migration-guide.html
