# GJS Core Notes

This file condenses the `gjs.guide` pages that matter most for day-to-day coding.

## What GJS is

- GJS is JavaScript bindings for the GNOME platform.
- It is not a browser runtime and not Node.js.
- Common work is done through GNOME platform libraries like `Gio`, `GLib`, `Gtk`, `GObject`, and others documented at `gjs-docs.gnome.org`.

## Module system

- Prefer standard ES modules.
- Prefer `gi://` imports for platform libraries.
- Include file extensions for local JavaScript modules.
- Prefer migration away from legacy `imports.*` patterns in existing code when practical.

Example:

```js
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import Gtk from 'gi://Gtk?version=4.0';

import * as Utils from './lib/utils.js';
```

## Runtime conveniences

Modern GJS includes:

- `console`
- `TextEncoder`
- `TextDecoder`
- `setTimeout`
- `setInterval`
- `clearTimeout`
- `clearInterval`

Do not mistake that for full browser API coverage. Use platform libraries for the rest.

## Async model

- Concurrency is driven by GLib's event loop.
- Many Gio APIs have async variants that execute work off the main thread and complete back on the main loop.
- `async` / `await` is the preferred way to structure asynchronous code.
- Use `Gio._promisify()` to wrap callback-style Gio async methods.

General rule:

- blocking sync IO is acceptable only for tiny non-UI scripts
- UI code should use async Gio APIs

## Style conventions

From the GJS style guide:

- prefer `const` / `let` over `var`
- prefer ES modules
- prefer `console.log()` / `console.error()`
- prefer `class` and `constructor()` over older class helpers and `_init()`
- keep imports grouped cleanly
- use `export` for public symbols

The guide also documents ESLint, Prettier, and EditorConfig setups commonly used in GJS projects. Use them when the user wants project scaffolding or linting conventions, but do not add tooling unless it matches the task.

## Memory and lifecycle

GJS combines:

- JavaScript reference tracing
- GObject reference counting

Practical consequences:

- losing a signal or timeout ID can leak behavior and references
- callbacks can keep objects alive longer than expected
- destroyed objects can still be traced from JavaScript variables, causing use-after-free if touched
- Cairo drawing contexts should be disposed with `cr.$dispose()`

Keep cleanup explicit when objects outlive a single local scope.

## Source pages

- Guides index: https://gjs.guide/guides/
- Intro: https://gjs.guide/guides/gjs/intro.html
- Asynchronous Programming: https://gjs.guide/guides/gjs/asynchronous-programming.html
- Style Guide: https://gjs.guide/guides/gjs/style-guide.html
- Memory Management: https://gjs.guide/guides/gjs/memory-management.html
