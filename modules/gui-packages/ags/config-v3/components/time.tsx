import GLib from 'gi://GLib';
import Gtk from 'gi://Gtk?version=4.0';
import { With, createBinding } from 'ags';
import { createPoll } from 'ags/time';
import { shellState } from '../shell/state';
import { isVertical } from '../shell/layout';

export default function Time() {
  const orientation = createBinding(shellState, 'orientation');
  const hour = createPoll('', 1000, () =>
    GLib.DateTime.new_now_local().format('%H') ?? '--',
  );
  const minute = createPoll('', 1000, () =>
    GLib.DateTime.new_now_local().format('%M') ?? '--',
  );
  const date = createPoll('', 60_000, () =>
    GLib.DateTime.new_now_local().format('%a %e %b') ?? '',
  );
  const horizontalTime = createPoll('', 1000, () =>
    GLib.DateTime.new_now_local().format('%H:%M') ?? '--:--',
  );

  return (
    <box
      class={orientation((current) =>
        isVertical(current) ? 'rail-module' : 'rail-module rail-time',
      )}
      halign={orientation((current) =>
        isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
      )}
      hexpand={orientation(isVertical)}
    >
      <With value={orientation}>
        {(current) =>
          current &&
          (isVertical(current) ? (
            <box
              class="rail-time rail-time-vertical"
              orientation={Gtk.Orientation.VERTICAL}
              spacing={2}
              halign={Gtk.Align.FILL}
              hexpand
            >
              <label class="rail-time-primary rail-time-primary-vertical" label={hour} />
              <label class="rail-time-primary rail-time-primary-vertical" label={minute} />
            </box>
          ) : (
            <box class="rail-time" orientation={Gtk.Orientation.HORIZONTAL} spacing={6}>
              <label class="rail-time-primary" label={horizontalTime} />
              <label class="rail-time-secondary" label={date} />
            </box>
          ))
        }
      </With>
    </box>
  );
}
