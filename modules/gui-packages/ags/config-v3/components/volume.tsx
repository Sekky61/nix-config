import AstalWp from 'gi://AstalWp';
import Gtk from 'gi://Gtk?version=4.0';
import { With, createBinding } from 'ags';
import { shellState } from '../shell/state';
import { isVertical } from '../shell/layout';

const wp = AstalWp.get_default();

export default function Volume() {
  const speaker = wp?.defaultSpeaker;
  const orientation = createBinding(shellState, 'orientation');

  if (!speaker) {
    return <box visible={false} />;
  }

  const volume = createBinding(speaker, 'volume')((value) =>
    `${Math.floor(value * 100)}%`,
  );
  const compactVolume = createBinding(speaker, 'volume')((value) =>
    `${Math.floor(value * 100)}`,
  );

  return (
    <menubutton
      class="rail-module rail-module-volume"
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
              class="rail-metric rail-metric-vertical rail-metric-volume-vertical"
              orientation={Gtk.Orientation.VERTICAL}
              spacing={2}
              halign={Gtk.Align.FILL}
              hexpand
            >
              <image iconName={createBinding(speaker, 'volumeIcon')} />
              <label class="rail-volume-label-vertical" label={compactVolume} />
            </box>
          ) : (
            <box
              class="rail-metric"
              orientation={Gtk.Orientation.HORIZONTAL}
              spacing={8}
              halign={Gtk.Align.FILL}
            >
              <image iconName={createBinding(speaker, 'volumeIcon')} />
              <label label={volume} />
            </box>
          ))
        }
      </With>
      <popover>
        <box class="rail-popover-list">
          <slider
            widthRequest={240}
            onChangeValue={({ value }) => speaker.set_volume(value)}
            value={createBinding(speaker, 'volume')}
          />
        </box>
      </popover>
    </menubutton>
  );
}
