import AstalHyprland from 'gi://AstalHyprland';
import Gtk from 'gi://Gtk?version=4.0';
import { For, createBinding } from 'ags';
import { shellState } from '../shell/state';
import { isVertical } from '../shell/layout';

const hyprland = AstalHyprland.get_default();

function visibleWorkspaces(workspaces: Array<AstalHyprland.Workspace>) {
  return workspaces
    .filter((workspace) => !(workspace.id >= -99 && workspace.id <= -2))
    .sort((left, right) => left.id - right.id);
}

export default function Workspaces() {
  const orientation = createBinding(shellState, 'orientation');
  const workspaces = createBinding(hyprland, 'workspaces')(visibleWorkspaces);
  const focusedWorkspace = createBinding(hyprland, 'focusedWorkspace');
  const monitors = createBinding(hyprland, 'monitors');

  return (
    <box
      class="rail-section rail-workspaces"
      orientation={orientation((current) =>
        isVertical(current) ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL,
      )}
      spacing={8}
      halign={orientation((current) =>
        isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
      )}
      hexpand={orientation(isVertical)}
    >
      <For each={workspaces}>
        {(workspace) => (
          <button
            class={focusedWorkspace((focused) =>
              focused === workspace ? 'workspace-chip workspace-chip-active' : 'workspace-chip',
            )}
            onClicked={() => workspace.focus()}
            halign={orientation((current) =>
              isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
            )}
            hexpand={orientation(isVertical)}
          >
            <box
              class={orientation((current) =>
                isVertical(current) ? 'workspace-chip-box workspace-chip-box-vertical' : 'workspace-chip-box',
              )}
              orientation={orientation((current) =>
                isVertical(current) ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL,
              )}
              spacing={orientation((current) => (isVertical(current) ? 4 : 8))}
              halign={orientation((current) =>
                isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
              )}
              hexpand={orientation(isVertical)}
            >
              <label label={`${workspace.id}`} />
              <box
                class="workspace-monitor-dot"
                visible={monitors((items) => items.length > 1)}
              />
            </box>
          </button>
        )}
      </For>
    </box>
  );
}
