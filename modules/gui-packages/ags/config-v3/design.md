# AGS Config v3 Design Doc

## Purpose

Define the target architecture and UX goals for the AGS v3 desktop shell config, with initial focus on the main desktop sidebar / toolbar experience and migration constraints from the older AGS config.

This is a working document. Sections marked as open are pending requirement decisions.

## Current repo state

- Home Manager already points AGS at `modules/gui-packages/ags/config-v3/`.
- `config-v3` is currently a small GTK4 / AGS v3 sample app with one `Bar` window per monitor.
- The old AGS config under `modules/gui-packages/ags/config/` contains the better product ideas:
  - toggleable vertical / horizontal bar orientation
  - Hyprland workspace widget
  - grouped shell widgets and tray
  - styling groundwork for left / right sidebars
- The old AGS config should be treated primarily as a record of product intent, not as a technical reference implementation. It is useful for UX ideas and visual language, but it is not a good pattern source for AGS v3 structure.
- `scripts/dev-ags` still launches the old config directory, which should be treated as migration debt to resolve once v3 is usable.

## Confirmed requirements

- The shell must support both a vertical toolbar and a horizontal toolbar.
- Toolbar orientation must be toggleable at runtime.
- Hyprland desktops / workspaces must be present in the shell UI.
- The "desktop sidebar" is the main always-visible rail, not a separate secondary panel.
- Vertical mode lives on the right side.
- Horizontal mode lives on the top side.
- Vertical and horizontal modes should expose the same core information and controls, only rearranged for axis.
- The always-visible core set should include:
  - Hyprland workspaces
  - battery
  - time
  - status / tray indicators
  - volume
  - brightness
- The shell should support saving user preferences across restarts.
- In vertical mode, battery percent should be visible.
- In vertical mode, time text should be visible.
- The rail should appear on all monitors.
- A focused window title is not required in the main rail.
- Rail elements should be designed as interactive controls, even if richer interactions land incrementally.
- Volume should show icon and value in the rail.
- Brightness should show icon and value in the rail.
- Orientation can be global across all monitors.
- On first run, the default layout should be the right-side vertical rail.
- Scroll-to-switch for workspaces is a nice later enhancement, not a phase-1 requirement.
- Special Hyprland workspaces do not need to be surfaced.
- Workspace monitor markers are desirable.
- Workspace icons are worth exploring as an option.
- The rail should be thin but well spaced out.
- Phase 1 should stay rail-only, with no calendar panel and no notifications panel.
- The v1 visual style is a strong starting point for v3.
- Workspace icons should be derived from the active app where feasible.
- Density presets are useful, but can land later.
- Monitor markers should use subtle dots.
- The rail should use a softer dark surface rather than pure OLED black.
- Time should receive the strongest visual emphasis outside the workspace section.
- Media controls should exist at least as an indicator.
- Power actions are definitely in scope.

## Product goal

Build a clean AGS v3 shell that keeps the useful product ideas from v1 while accepting that the implementation should be a ground-up rewrite in AGS v3 patterns, not a line-by-line port.

## UX direction

### Desktop sidebar / toolbar

The desktop shell should behave like a rail-first control surface rather than just a thin status bar.

Initial direction:

- Vertical mode should feel like a desktop rail: compact, glanceable, and easy to target with the pointer.
- Horizontal mode should feel like a more conventional top bar, with the same core modules rearranged rather than redesigned.
- The product is one shell surface with two layouts:
  - right-side vertical rail
  - top horizontal bar
- Orientation changes should preserve user mental model:
  - same modules
  - same interaction entry points
  - same visual grouping
  - different axis and anchoring
- Hyprland workspaces should remain a primary navigation element, not a secondary status item.
- Battery, time, tray/status, volume, and brightness are baseline shell affordances, not optional extras.

### UX principles

- Glanceable first: current workspace, time, battery, tray, and active-state indicators should be visible without opening popovers.
- Progressive disclosure: richer controls should live behind popovers or expandable sidebar sections.
- Stable muscle memory: module order should stay predictable across restarts and orientation changes.
- Low visual noise: the shell should read as one coherent surface, not a pile of disconnected widgets.
- Monitor-aware behavior should be explicit in design, not accidental.
- Interactive by default: each rail module should be capable of doing something useful on click, scroll, or secondary action, but initial implementation can phase this in.
- Thin, not cramped: the rail should stay narrow, but spacing and grouping should still make it feel intentional and polished.

### Feature options worth considering

These are plausible features for this shell that match the current direction. They are not all phase-1 requirements.

- Workspace monitor markers
  - Small colored dots, glyphs, or edge accents to show which monitor a workspace belongs to.
- Workspace identity modes
  - Numeric only
  - Numeric plus icon
  - Numeric plus app hint for the active workspace
- Volume and brightness quick interactions
  - Click opens slider popover
  - Scroll adjusts value directly
  - Middle click toggles mute or returns to auto-brightness preset if supported
- Battery detail popover
  - Percent, charging state, time remaining, power profile shortcuts
- Time detail popover
  - Secondary date line, timezone, copy date/time actions
- Tray overflow handling
  - Keep the rail thin by collapsing less-important tray icons behind one entry point when crowded
- Multi-monitor awareness
  - Dim workspaces that belong to other monitors
  - Highlight the local monitor's currently focused workspace more strongly
- Rail density presets
  - `compact`
  - `comfortable`
  - useful if the initial thin layout later needs a supported alternate mode
- Media indicator
  - Minimal now-playing presence in the rail without turning the shell into a full media bar
- Power actions
  - Fast access entry point for lock, suspend, reboot, shutdown, logout

## Proposed technical direction

### Stack

- AGS v3
- GTK4
- Astal libraries via GI imports
- TypeScript + JSX
- SCSS for styling

### Architecture outline

Suggested v3 structure:

- `app.tsx`
  - app bootstrap
  - global stylesheet
  - monitor enumeration
  - construction of shell windows
- `shell/`
  - top-level shell composition and runtime state
- `windows/`
  - monitor-bound windows such as toolbar / sidebar
- `components/`
  - reusable UI modules such as workspaces, tray, clock, battery, media
- `services/`
  - AGS / Astal-backed state adapters
- `style/`
  - split SCSS by shell surface and shared tokens

This is intentionally more modular than the current one-file `bar.tsx` sample.

### Runtime state

Expected shared UI state:

- toolbar orientation: `vertical | horizontal`
- persisted user preferences
- per-monitor shell instance state where needed

In v3 terms, this should be built around AGS reactive state primitives rather than the old `Variable` pattern.

Expected persisted preferences:

- last selected orientation
- any future display-density or module-visibility settings, if those are introduced later

### Windows

Expected window model:

- one primary shell window per monitor
- that window can render either as:
  - a right-anchored vertical rail
  - a top-anchored horizontal bar

Current preferred direction:

- a single adaptive shell window is the default architecture
- additional windows should be added only for genuinely separate surfaces such as notifications or larger popovers, not for the main rail itself

### Hyprland integration

The old config already proves the need for Hyprland workspaces. In v3 this should likely be rebuilt around `AstalHyprland` with:

- reactive workspace list
- focused workspace binding
- click-to-focus behavior
- filtering of special workspaces unless a deliberate UX case is defined for them
- optional monitor ownership indicator when multiple monitors are active
- scroll-to-switch can be added later as an enhancement, not a required baseline feature

This component should be shown on every monitor, since the rail itself is multi-monitor.

### Orientation handling

v1 had a good product idea here: orientation is a first-class shell mode, not just a CSS tweak.

For v3, orientation should drive:

- window anchors
- container orientation
- module ordering
- spacing and sizing rules
- icon-only vs icon-plus-label behavior where needed
- which groups are allowed to expand vs stay compact

This suggests a small shared layout model rather than scattered `if vertical` checks everywhere.

### Commands and control surface

The old config exposed runtime requests for:

- `bar-vertical`
- `bar-horizontal`
- `bar-toggle`

v3 should preserve an equivalent external control path so keybinds or scripts can switch shell orientation without restarting AGS.

Open decision:

- keep AGS request-based commands
- expose a different v3-native command interface if simpler

Preferences should also allow the chosen orientation to persist across AGS restarts.

## Technical architecture

### Target source layout

Recommended `config-v3` structure:

```text
config-v3/
  app.tsx
  design.md
  shell/
    state.ts
    preferences.ts
    commands.ts
    layout.ts
    types.ts
  windows/
    rail-window.tsx
  components/
    workspaces.tsx
    time.tsx
    battery.tsx
    volume.tsx
    brightness.tsx
    tray.tsx
    media-indicator.tsx
    power-button.tsx
    group.tsx
  services/
    hyprland.ts
    battery.ts
    audio.ts
    media.ts
    tray.ts
    brightness.ts
    power.ts
  style/
    index.scss
    tokens.scss
    rail.scss
    workspaces.scss
    modules.scss
    popovers.scss
```

This keeps a hard boundary between:

- shell-wide state and orchestration
- monitor-bound window composition
- reusable presentational components
- integration services and local adapters
- styling tokens and module-specific rules

### Boot sequence

Preferred startup flow:

1. `app.tsx` imports global styles and starts AGS with `app.start({ ... })`.
2. A shell bootstrap step loads persisted preferences before the first rail is rendered.
3. `requestHandler` is registered so compositor keybinds and scripts can change orientation or trigger actions.
4. Monitor windows are created with `<For each={createBinding(app, 'monitors')}>`.
5. Each monitor gets one `RailWindow` with `gdkmonitor`, while all shared shell state comes from `shell/state.ts`.

The important pattern is:

- global state is initialized once
- monitor windows are fanned out reactively
- no heavyweight widget instances are created at module top level

### Core type model

Suggested shared types:

```ts
export type Orientation = 'vertical' | 'horizontal';

export type RailSection = 'workspaces' | 'time' | 'system' | 'media' | 'power';

export type WorkspaceFallbackMode = 'number' | 'generic-glyph' | 'last-known-app';

export interface ShellPreferences {
  orientation: Orientation;
}

export interface RailLayoutSpec {
  orientation: Orientation;
  anchor: number;
  windowName: string;
  rootClass: string;
  sectionOrder: RailSection[];
}
```

These types should stay small and stable. Avoid modeling every widget detail globally.

### State architecture

Use two layers of state:

1. Shell UI state
2. System integration state

Shell UI state should own:

- current orientation
- loaded preference status
- future UI-only settings such as density preset or module visibility

System integration state should usually not be copied into shell state. It should stay bound directly to Astal-backed objects.

Recommended rule:

- use `createState` for UI decisions
- use `createBinding` for Astal and GObject-backed properties
- use `createComputed` only for layout-ready derived values

This avoids turning the app into a second state store on top of Astal.

### Service architecture

There should be two categories of service modules.

Astal-backed services:

- Hyprland
- Battery
- WirePlumber audio
- MPRIS media
- Tray
- PowerProfiles

Local adapter services:

- preferences persistence
- brightness integration
- any shell-only command or helper layer

Pattern to follow:

- if Astal already exposes the state, bind to it directly
- if Astal does not expose a capability, write a small adapter around the external tool or file watch
- keep adapters narrow and explicit about fallback behavior

Brightness is the clearest example of this split. Audio, battery, tray, and media can stay mostly Astal-native. Brightness may need a local adapter backed by `brightnessctl` and `/sys/class/backlight` monitoring.

### Component architecture

Each visible rail module should have one of these shapes:

- direct widget component
- widget plus popover pair
- widget plus service adapter

Examples:

- `Workspaces`
  - binds to Hyprland workspaces and focused workspace
  - renders buttons, monitor dots, and active-app-derived icon or fallback
- `Time`
  - polls local time
  - owns the strongest typographic emphasis
  - optional popover for secondary date details later
- `Volume`
  - binds to WirePlumber speaker state
  - shows icon and numeric or percent value
  - opens a slider popover on click
- `Brightness`
  - binds to local brightness adapter
  - shows icon and numeric or percent value
  - opens a slider popover on click
- `MediaIndicator`
  - binds to MPRIS players
  - phase 1 can show now-playing presence or playback state without full transport UI
- `PowerButton`
  - opens power actions

Keep component rules strict:

- components should not load files or own persistence
- components can call service actions from event handlers
- components should accept only the props needed for rendering or monitor context

### Slot-based layout pattern

Do not make every module individually decide how to behave for every orientation.

Instead, define a layout spec per orientation that maps rail sections into slots.

Example approach:

```ts
const verticalLayout: RailLayoutSpec = {
  orientation: 'vertical',
  anchor: RIGHT | TOP | BOTTOM,
  windowName: 'rail-vertical',
  rootClass: 'rail rail-vertical',
  sectionOrder: ['workspaces', 'media', 'time', 'system', 'power'],
};
```

```ts
const horizontalLayout: RailLayoutSpec = {
  orientation: 'horizontal',
  anchor: TOP | LEFT | RIGHT,
  windowName: 'rail-horizontal',
  rootClass: 'rail rail-horizontal',
  sectionOrder: ['workspaces', 'time', 'media', 'system', 'power'],
};
```

Then `RailWindow` can render sections through a shared slot renderer rather than spreading orientation conditionals everywhere.

This is the main structural pattern that will keep the shell maintainable.

### Window composition

Preferred window composition:

- one `RailWindow` per monitor
- each window receives:
  - `gdkmonitor`
  - current orientation
  - layout spec
- each window owns only monitor-specific widget tree concerns

The rail window should handle:

- choosing the right `Astal.WindowAnchor`
- exclusive reservation
- visible root container
- orientation classes
- section stacking and spacing

The rail window should not own:

- persistence
- command parsing
- raw system integrations

### Persistence pattern

Use one small preferences module for persisted UI settings.

Responsibilities:

- load preferences at startup
- validate and normalize them
- expose read and write helpers
- write only UI-owned settings, not live system state

Likely storage contents for phase 1:

```json
{
  "orientation": "vertical"
}
```

Recommended persistence behavior:

- read once during bootstrap
- update immediately when orientation changes
- fall back cleanly to defaults if the file is missing or invalid

Implementation options:

- GLib/Gio file read and write
- JSON file in a user-scoped config or state path

### Command and request API

Keep runtime control intentionally small.

Phase-1 commands should likely include:

- `rail-vertical`
- `rail-horizontal`
- `rail-toggle`
- `rail-power`

Possible later commands:

- `rail-open-media`
- `rail-open-system`
- `rail-density-compact`
- `rail-density-comfortable`

Use AGS `requestHandler(argv, response)` as the integration point. Hyprland keybinds should call `ags request ...` rather than trying to manipulate widget state directly.

### Reactivity rules

Recommended rules for this codebase:

- prefer direct `createBinding` against Astal objects
- derive values as close to the consuming widget as possible
- export shell state accessors from one central module
- avoid large stores that duplicate Astal object state
- avoid polling except for clock or truly missing signals

This should be the default decision tree:

1. Does Astal already expose the state?
2. If yes, bind directly with `createBinding`.
3. If no, can a small local GObject adapter expose it?
4. Only then introduce polling or shell commands.

### Styling architecture

Styling should follow the same separation as the code:

- `tokens.scss`
  - color tokens
  - spacing scale
  - radius scale
  - typography rules
- `rail.scss`
  - root rail geometry
  - vertical and horizontal layout classes
- `workspaces.scss`
  - workspace pills, active state, monitor dots, icon sizing
- `modules.scss`
  - battery, volume, brightness, tray, time, media, power modules
- `popovers.scss`
  - menus and slider popovers

CSS guidance:

- keep visual tokens centralized
- prefer classes over inline `css`
- keep GTK-specific selectors shallow and intentional
- avoid encoding layout decisions only in CSS when they really belong in the layout spec

### v3 coding patterns to standardize

Patterns to adopt:

- `app.start` entrypoint only
- `<For each={createBinding(app, 'monitors')}>` for monitor fan-out
- `gdkmonitor={monitor}` for monitor-aware windows
- function components for most widgets
- `$` setup hooks only for imperative widget wiring
- popovers with `Gtk.Popover`
- small adapter modules instead of large mixed services

Patterns to avoid:

- AGS v1-style global mutable app structure
- extending a giant `bar.tsx` indefinitely
- duplicating Astal object state into app-local stores
- shelling out where an Astal library already exists
- letting style classes become the architecture

### Failure and fallback strategy

The rail should degrade predictably when integrations are missing.

Expected fallbacks:

- workspace icon missing
  - fall back to workspace number
- no active media player
  - hide or dim media indicator
- brightness adapter unavailable
  - hide the brightness control or show read-only state
- tray item without icon
  - use fallback symbolic icon if possible
- bad preferences file
  - reset to defaults and continue

Design principle:

- missing integrations should remove or reduce one module, not destabilize the whole shell

### Implementation phases

Suggested technical rollout:

1. Shell skeleton
   - state module
   - preferences module
   - commands
   - `RailWindow`
   - vertical and horizontal layout switching
2. Core modules
   - workspaces
   - time
   - battery
   - volume
   - brightness
   - tray
3. Interaction pass
   - volume popover
   - brightness popover
   - power actions
   - media indicator
4. Refinement
   - active-app-derived workspace icons
   - monitor dots
   - scroll interactions
   - density presets

This order keeps the architecture stable before adding polish.

### Visual direction from v1

The old bar styling suggests a visual language worth carrying into v3:

- very dark, near-OLED-black shell background
- rounded grouped capsules instead of one flat strip
- clear active workspace pills
- compact controls with deliberate padding
- strong contrast between passive and active states

Likely v3 interpretation:

- keep the grouped capsule rhythm from v1
- keep the dark rail background, but modernize tokens and spacing
- make the rail thin overall, with more disciplined whitespace than v1
- prefer a polished, status-dense aesthetic over a default Adwaita look
- bias toward a softer dark surface instead of absolute black so active states and grouping can breathe
- give time the clearest typographic emphasis among the non-workspace modules

## Migration notes from v1

Keep:

- runtime orientation switching
- workspace prominence
- grouped module layout
- rail concept and visual language where still useful

Do not preserve by default:

- old file structure
- GTK3 widget patterns
- `Variable` / `bind` state style
- giant mixed-purpose files

Explicit stance on v1:

- v1 is valuable as a statement of intent
- v1 is not a strong reference for architecture or implementation patterns
- if v1 and AGS v3 idioms conflict, v3 patterns win
- migration should prefer reinterpretation over porting

## Open requirements

These answers will decide the actual v3 structure.

### 1. Sidebar shape

Resolved:

- The "desktop sidebar" is the same surface as the toolbar.
- Vertical mode is right-anchored.
- Horizontal mode is top-anchored.

Still open:

- Whether any secondary expandable panels should exist at all, beyond normal popovers

### 2. Monitor behavior

Confirmed:

- The full rail should appear on every monitor.
- Workspace controls should therefore also appear on every monitor unless later UX decisions narrow their content.
- Orientation is shared globally across monitors.

Open:

- Should each monitor show the same workspace list, or should the local monitor be emphasized somehow?

### 3. Workspace UX

Confirmed:

- Special workspaces can stay hidden.
- Scroll-to-switch is desirable but can land after phase 1.
- Workspace monitor markers are desirable.
- Workspace icons should be derived from the active app where feasible.

Open:

- How to fall back when no suitable active-app icon is available:
  - number only
  - generic workspace glyph
  - cached previous app icon

### 4. Toolbar content priorities

Confirmed:

- Always-visible priorities include battery, time, status / tray, volume, and brightness in addition to workspaces.
- The same core set should exist in both orientations.
- Battery percent and time text should remain visible in vertical mode.
- A focused window title is not required.
- Volume and brightness should show both icon and value in the rail.
- Time should receive the strongest visual emphasis outside the workspace section.
- Media controls should exist at least as an indicator.
- Power actions are in scope.

Open:

- Which of those should show only an icon by default in vertical mode
- Which of those should expand into sliders or richer controls on click
- Which modules deserve scroll interactions in addition to click

### 5. Sidebar content priorities

Open:

- Since the main shell is the rail itself, what secondary surfaces still matter?
- Current likely scope:
  - quick settings popovers
  - power actions
  - media indicator with optional lightweight controls
  - maybe launcher

### 6. Orientation semantics

Confirmed:

- The shell should remember the last chosen orientation across restarts.
- Orientation can be global across all monitors.
- The first-run default should be the right-side vertical rail.

Open:

- Whether any per-monitor override is worth supporting later, or should remain out of scope

### 7. Visual direction

Confirmed:

- The v1 visual style is a strong starting point.
- The rail should be thin but well spaced out.
- Looks matter; style should be discussed explicitly rather than left as an implementation detail.
- The rail should use a softer dark surface rather than pure OLED black.
- Time should be the most visually emphasized non-workspace module.
- Density presets can be deferred until later.

Open:

- How much color should appear outside active states and monitor markers
- How expressive active-app workspace icons should be versus how restrained the overall rail should stay

## Initial recommendation

Unless later requirements push against it, the cleanest v3 plan is:

- one shared shell state service
- one monitor-scoped shell window per monitor
- a primary rail that supports right-side vertical and top horizontal modes
- popovers for richer controls such as volume, brightness, tray menus, and system actions
- a dedicated Hyprland workspace component built early, because it is a core navigation primitive
- preference persistence for orientation and future shell settings
- phase 1 should prioritize correct layout, persistence, and baseline interactions before richer module behaviors
- phase 1 can intentionally skip workspace scroll switching and other interaction polish that does not affect core information architecture
- phase 1 should include a media presence in the rail, but it can start as an indicator instead of full transport controls
- phase 1 should include a power actions entry point

That keeps the user-facing model simple while avoiding the old config's tight coupling.

## Next requirement pass

Immediate questions for the next round:

1. For active-app-derived workspace icons, what should the fallback be when the workspace is empty or the app has no good icon:
   number, generic glyph, or last-known app icon?
2. Should the media indicator be:
   icon only, app icon plus state, or short track text when space allows?
3. Should power actions live behind one dedicated button, or inside a broader system popover with battery / brightness / volume details?
4. For color usage, do you want mostly monochrome modules with color only for active and warning states, or more color throughout?
5. Should the top horizontal mode keep the exact same group order as the right rail, or should time move closer to center for emphasis?
