# GObject And Gio Notes

Use this file when the task is about GNOME object models, file IO, subprocesses, settings, or inter-process communication.

## GObject basics

- Most GNOME platform objects are GObjects.
- Construct them with `new ClassName({ property: value })` when supported.
- Some types such as `Gio.File` are created through constructor functions like `Gio.File.new_for_path(...)`.
- Prefer native property access like `widget.visible = true` where possible.
- Signal connections should retain handler IDs when cleanup or disconnection matters.

## GObject subclassing

- Use `GObject.registerClass(...)` for subclasses.
- In modern GJS, prefer `constructor()` and `super(...)`.
- `_init()` is legacy compatibility territory.
- Declare GObject properties and signals in the registration metadata when you need them to participate in the type system.

Example shape:

```js
import GObject from 'gi://GObject';

export const Example = GObject.registerClass({
    GTypeName: 'Example',
    Properties: {
        'enabled': GObject.ParamSpec.boolean(
            'enabled',
            'Enabled',
            'Whether the object is enabled',
            GObject.ParamFlags.READWRITE,
            false
        ),
    },
    Signals: {
        changed: {},
    },
}, class Example extends GObject.Object {
    constructor(params = {}) {
        super(params);
    }
});
```

## Gio file IO

- Use `Gio.File` for file abstraction and IO.
- Prefer async methods for UI code.
- `Gio.File` supports create, replace, copy, move, delete, enumerate, and content loading.
- Use the relevant `Gio.File*Flags` enums rather than shelling out to `cp`, `mv`, or `rm`.

## Gio subprocesses

- Prefer `Gio.Subprocess` over `GLib.spawn_*`.
- `Gio.Subprocess` is safer and more convenient in GJS.
- Promisify async methods such as:
  - `communicate_async`
  - `communicate_utf8_async`
  - `wait_async`
  - `wait_check_async`

Good default pattern:

```js
import Gio from 'gi://Gio';

Gio._promisify(Gio.Subprocess.prototype, 'communicate_utf8_async');

const proc = Gio.Subprocess.new(
    ['ls', '/'],
    Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
);

const [stdout, stderr] = await proc.communicate_utf8_async(null, null);
```

Always check success and propagate useful stderr on failure.

## D-Bus and actions

- Use `Gio.DBusConnection` or higher-level helpers for D-Bus work.
- Remember D-Bus payloads are `GLib.Variant` based.
- Use `Gio.SimpleAction` and `Gio.MenuModel` for application actions, menus, and remotely activatable behavior.

## Gtk note

The `gjs.guide` index points GTK4 readers to external GTK docs and books rather than re-explaining the whole widget toolkit. For GTK4 application structure and widget behavior, pair this skill with:

- GNOME developer docs
- GTK4 Book
- local project patterns

## Source pages

- GObject basics: https://gjs.guide/guides/gobject/basics.html
- GObject subclassing: https://gjs.guide/guides/gobject/subclassing.html
- Gio file operations: https://gjs.guide/guides/gio/file-operations.html
- Gio subprocesses: https://gjs.guide/guides/gio/subprocesses.html
- Gio actions and menus: https://gjs.guide/guides/gio/actions-and-menus.html
- Gio D-Bus: https://gjs.guide/guides/gio/dbus.html
