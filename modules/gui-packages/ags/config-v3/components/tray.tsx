import Gtk from 'gi://Gtk?version=4.0';
import AstalTray from 'gi://AstalTray';
import { For, createBinding } from 'ags';
import { shellState } from '../shell/state';
import { isVertical } from '../shell/layout';

const tray = AstalTray.get_default();

function setupTrayButton(button: Gtk.MenuButton, item: AstalTray.TrayItem) {
  button.menuModel = item.menuModel;
  button.insert_action_group('dbusmenu', item.actionGroup);

  item.connect('notify::action-group', () => {
    button.insert_action_group('dbusmenu', item.actionGroup);
  });
}

export default function Tray() {
  const items = createBinding(tray, 'items');
  const orientation = createBinding(shellState, 'orientation');

  return (
    <box
      class="rail-module rail-tray"
      orientation={orientation((current) =>
        isVertical(current) ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL,
      )}
      spacing={4}
      halign={orientation((current) =>
        isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
      )}
      hexpand={orientation(isVertical)}
    >
      <For each={items}>
        {(item) => (
          <menubutton
            class="rail-tray-item"
            halign={orientation((current) =>
              isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
            )}
            hexpand={orientation(isVertical)}
            $={(self) => setupTrayButton(self, item)}
          >
            <image gicon={createBinding(item, 'gicon')} />
          </menubutton>
        )}
      </For>
    </box>
  );
}
