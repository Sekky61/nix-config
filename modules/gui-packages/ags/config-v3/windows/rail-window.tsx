import { createBinding, onCleanup } from 'ags';
import app from 'ags/gtk4/app';
import Astal from 'gi://Astal?version=4.0';
import Gdk from 'gi://Gdk?version=4.0';
import Gtk from 'gi://Gtk?version=4.0';
import Battery from '../components/battery';
import MediaIndicator from '../components/media-indicator';
import Time from '../components/time';
import Tray from '../components/tray';
import Volume from '../components/volume';
import Wireless from '../components/wireless';
import Workspaces from '../components/workspaces';
import { getGtkOrientation, getWindowAnchor, isVertical } from '../shell/layout';
import { shellState } from '../shell/state';

function setupRailWindow(window: Astal.Window) {
  window.add_css_class('rail-window');
}

export default function RailWindow({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  let windowRef: Astal.Window;
  const orientation = createBinding(shellState, 'orientation');

  onCleanup(() => {
    windowRef.destroy();
  });

  return (
    <window
      $={(self) => {
        windowRef = self;
        setupRailWindow(self);
      }}
      visible
      name={`rail-${gdkmonitor.connector}`}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={orientation(getWindowAnchor)}
      application={app}
    >
      <centerbox
        class={orientation((current) =>
          isVertical(current) ? 'rail-surface rail-surface-vertical' : 'rail-surface',
        )}
        orientation={orientation(getGtkOrientation)}
      >
        <box
          $type="start"
          class="rail-zone rail-zone-start"
          orientation={orientation(getGtkOrientation)}
          spacing={10}
          halign={orientation((current) =>
            isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
          )}
          hexpand={orientation((current) => !isVertical(current))}
        >
          <Workspaces />
        </box>
        <box
          $type="center"
          class={orientation((current) =>
            isVertical(current) ? 'rail-zone rail-zone-center rail-zone-center-vertical' : 'rail-zone rail-zone-center',
          )}
          orientation={orientation(getGtkOrientation)}
          spacing={10}
          hexpand={orientation((current) => !isVertical(current))}
          vexpand={orientation(isVertical)}
          halign={orientation((current) =>
            isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
          )}
        >
          <MediaIndicator />
        </box>
        <box
          $type="end"
          class={orientation((current) =>
            isVertical(current) ? 'rail-zone rail-zone-end rail-zone-end-vertical' : 'rail-zone rail-zone-end',
          )}
          orientation={orientation(getGtkOrientation)}
          spacing={orientation((current) => (isVertical(current) ? 10 : 8))}
          halign={orientation((current) =>
            isVertical(current) ? Gtk.Align.FILL : Gtk.Align.END,
          )}
          hexpand={orientation((current) => !isVertical(current))}
        >
          <Wireless />
          <Tray />
          <Volume />
          <Battery />
          <Time />
        </box>
      </centerbox>
    </window>
  );
}
