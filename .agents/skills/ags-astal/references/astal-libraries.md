# Astal Libraries Notes

Astal is the backend library suite. AGS handles app structure and JSX; Astal handles system integration and GTK-oriented shell primitives.

## Mental model

- Use AGS for `app.start`, JSX widgets, reactivity helpers, CLI request handling, and utilities.
- Use Astal libraries for data and control surfaces like battery, tray, MPRIS, power profiles, apps, audio, and network.
- Use plain GTK widgets directly when there is no special Astal abstraction needed.

## Library selection

Common libraries surfaced in the AGS docs:

- `Apps`: app launchers and desktop entry lookup
- `Battery`: battery state
- `Mpris`: media players and playback control
- `Network`: Wi-Fi and network state
- `PowerProfiles`: power profile switching
- `Tray`: system tray items
- `WirePlumber`: audio devices and volume
- `Hyprland`, `Notifd`, `Bluetooth`, `River`, `Auth`, `Greet`, `Cava`

When a user asks for shell components like a battery widget, tray section, media controls, or volume popup, look for a matching Astal library first.

## Common JavaScript import patterns

```ts
import Apps from 'gi://AstalApps';
import Battery from 'gi://AstalBattery';
import Mpris from 'gi://AstalMpris';
import Network from 'gi://AstalNetwork';
import PowerProfiles from 'gi://AstalPowerProfiles';
import Tray from 'gi://AstalTray';
import Wp from 'gi://AstalWp';
```

Typical singleton usage:

```ts
const battery = Battery.get_default();
const mpris = Mpris.get_default();
const tray = Tray.get_default();
const network = Network.get_default();
const powerProfiles = PowerProfiles.get_default();
const wp = Wp.get_default();
```

Then bind properties with AGS:

```ts
import { createBinding } from 'ags';

const players = createBinding(mpris, 'players');
const percentage = createBinding(battery, 'percentage');
```

## Practical guidance

- Prefer `createBinding` against Astal objects instead of copying values into separate state unless you need local transformation or aggregation.
- Keep imperative actions near the UI event that triggers them, for example `onClicked={() => player.play_pause()}`.
- If a library does not expose a capability directly, document the fallback clearly before using `execAsync` or another shell command.
- If a GI-exposed property behaves badly as a list or throws pointer-conversion errors, look for an explicit getter method instead of reading the property directly.

## Example pattern: GTK4 notifications

The AGS GTK4 notifications example demonstrates a good component shape:

- small pure helpers for icon detection, file existence, time formatting, and urgency-to-class mapping
- one typed `NotificationProps` interface
- one presentational component that maps notification state into classes and conditional subtrees
- `Adw.Clamp` used as a layout constraint instead of relying on unsupported or awkward CSS max sizing
- `Pango.EllipsizeMode.END` and `wrap` used explicitly for text behavior
- image rendering split into file-backed and icon-backed branches
- action buttons rendered from `n.actions.map(...)`

Carry these patterns over when building other Astal-backed cards, popups, or list items.

## Docs to consult

- Astal intro: https://aylur.github.io/astal/guide/introduction
- Astal home: https://aylur.github.io/astal/
- Library guides are under `https://aylur.github.io/astal/guide/libraries/<name>`

Useful known pages:

- Mpris: https://aylur.github.io/astal/guide/libraries/mpris
- Tray: https://aylur.github.io/astal/guide/libraries/tray

If you need method or property-level detail, follow the library guide to its generated reference docs.
