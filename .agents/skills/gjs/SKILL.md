---
name: gjs
description: Write or update GNOME JavaScript (GJS) code using modern ES modules, `gi://` imports, Gio, GLib, GObject, and Gtk. Use this whenever the user mentions GJS, GNOME JavaScript, `gi://` imports, Gio, GLib, GObject, Gtk, GNOME desktop app code, async Gio APIs, subprocesses, GSettings, D-Bus, or GObject subclassing.
---

# GJS

Use this skill for plain GNOME JavaScript work. Prefer `gjs.guide` and `gjs-docs.gnome.org` mental models over Node.js or browser assumptions.

Read bundled references selectively:

- Read `references/gjs-core.md` for runtime, imports, async patterns, style, and lifecycle rules.
- Read `references/gobject-and-gio.md` when the task touches properties, signals, subclassing, files, subprocesses, D-Bus, or application settings.

## Defaults

- Prefer modern ES modules.
- Prefer `gi://` imports over legacy `imports.*`.
- Prefer Gio and GLib APIs over shell commands when working with files, subprocesses, settings, or D-Bus.
- Prefer `async`/`await` with `Gio._promisify()` for asynchronous Gio methods.
- Prefer `GObject.registerClass(...)` and `constructor()` for subclasses.
- Prefer `const` and `let`, not `var`.
- Use `console.log()` / `console.error()` instead of older `log()` helpers unless the project clearly uses them.

## Workflow

1. Inspect the local code first and identify:
   - Gtk version
   - module style
   - whether the code is a GTK app, CLI tool, GNOME Shell extension, or library
2. Match the project's existing versioned imports, for example `gi://Gtk?version=4.0`.
3. For new code, default to ES modules and explicit imports.
4. Choose the highest-level platform API that fits:
   - `Gio.File` for file IO
   - `Gio.Subprocess` for process execution
   - `Gio.Settings` for settings
   - `Gio.SimpleAction` / `Gio.MenuModel` for actions and menus
   - GObject properties and signals for stateful objects
5. Use async Gio methods instead of blocking synchronous calls unless the script is intentionally tiny and non-UI.
6. Keep lifecycle cleanup explicit: source IDs, signal IDs, cancellables, and destroyed widgets must stay tractable.

## Core rules

### Runtime model

- GJS is not Node.js and not the browser.
- Do not assume DOM, full Fetch, or Node built-ins exist.
- Use GNOME platform libraries such as `Gio`, `GLib`, `Gtk`, and `Soup` where appropriate.
- `console`, `TextEncoder`, `TextDecoder`, `setTimeout`, and `setInterval` are available globally in modern GJS.

### Imports

Preferred import style:

```js
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import Gtk from 'gi://Gtk?version=4.0';

import * as Utils from './lib/utils.js';
```

Rules:

- Include file extensions for local module imports.
- Use versioned GI imports when the library has multiple ABI versions.
- Do not introduce legacy `imports.gi` patterns in new code.

### GObject usage

- Construct objects with property dictionaries where possible.
- Prefer native property accessors like `label.visible = true`.
- Connect to signals explicitly and retain handler IDs when cleanup matters.
- For subclasses, use `GObject.registerClass(...)`.
- In new code, override `constructor()` rather than `_init()`.

Subclass skeleton:

```js
import GObject from 'gi://GObject';

export const MyObject = GObject.registerClass({
    Signals: {
        changed: {},
    },
}, class MyObject extends GObject.Object {
    constructor(params = {}) {
        super(params);
    }
});
```

### Async and Gio

- The event loop is GLib's main loop.
- Prefer async Gio methods in UI code.
- Use `Gio._promisify()` when you want `await`-friendly wrappers.
- Use `Promise.all()` for parallel independent IO when appropriate.

### Files and subprocesses

- Use `Gio.File` for file operations.
- Use `Gio.Subprocess` for processes.
- Avoid low-level `GLib.spawn_*` unless there is a strong reason.
- Treat subprocess stdout/stderr handling and exit status as first-class concerns.

### Memory and cleanup

- Keep references to source IDs if you will need to remove a timeout or idle callback.
- Keep references to signal handler IDs if disconnecting later matters.
- Avoid use-after-free by nulling or replacing references after destructive teardown.
- Be careful with callbacks that close over objects and extend their lifetime.
- Dispose Cairo contexts in draw callbacks with `cr.$dispose()`.

### Style

- Keep imports grouped and separated cleanly.
- Prefer modern JavaScript features.
- Use `export` instead of old global-public patterns.
- Keep code straightforward and explicit rather than clever.

## When to reach for which guide

- Imports, modules, runtime assumptions: `references/gjs-core.md`
- Async programming and promisify patterns: `references/gjs-core.md`
- GObject construction, properties, signals, subclassing: `references/gobject-and-gio.md`
- File IO, subprocesses, D-Bus, actions: `references/gobject-and-gio.md`

## Output expectations

When writing or editing GJS code:

- Keep the code aligned with the target Gtk / GJS version.
- Prefer platform-native APIs over shell or web-style substitutes.
- Explain any use of synchronous IO, shell fallbacks, or legacy import patterns.
- If the task is really AGS or Astal-specific rather than plain GJS, also use the repo-local `ags-astal` skill.
