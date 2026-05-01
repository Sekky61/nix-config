import AstalBattery from 'gi://AstalBattery';
import AstalPowerProfiles from 'gi://AstalPowerProfiles';
import Gtk from 'gi://Gtk?version=4.0';
import { With, createBinding } from 'ags';
import { shellState } from '../shell/state';
import { isVertical } from '../shell/layout';

const battery = AstalBattery.get_default();
const powerProfiles = AstalPowerProfiles.get_default();

export default function Battery() {
  const orientation = createBinding(shellState, 'orientation');
  const percent = createBinding(
    battery,
    'percentage',
  )((value) => `${Math.floor(value * 100)}%`);
  const compactPercent = createBinding(
    battery,
    'percentage',
  )((value) => `${Math.floor(value * 100)}`);

  const setProfile = (profile: string) => {
    powerProfiles.set_active_profile(profile);
  };

  return (
    <menubutton
      class="rail-module rail-module-battery"
      visible={createBinding(battery, 'isPresent')}
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
              class="rail-metric rail-metric-vertical rail-metric-battery-vertical"
              orientation={Gtk.Orientation.VERTICAL}
              spacing={2}
              halign={Gtk.Align.FILL}
              hexpand
            >
              <image iconName={createBinding(battery, 'iconName')} />
              <label class="rail-battery-label-vertical" label={compactPercent} />
            </box>
          ) : (
            <box
              class="rail-metric"
              orientation={Gtk.Orientation.HORIZONTAL}
              spacing={8}
              halign={Gtk.Align.FILL}
            >
              <image iconName={createBinding(battery, 'iconName')} />
              <label label={percent} />
            </box>
          ))
        }
      </With>
      <popover>
        <box class="rail-popover-list" orientation={Gtk.Orientation.VERTICAL}>
          {powerProfiles.get_profiles().map(({ profile }) => (
            <button onClicked={() => setProfile(profile)}>
              <label label={profile} xalign={0} />
            </button>
          ))}
        </box>
      </popover>
    </menubutton>
  );
}
