import AstalNetwork from 'gi://AstalNetwork';
import Gtk from 'gi://Gtk?version=4.0';
import { For, With, createBinding } from 'ags';
import { execAsync } from 'ags/process';
import { shellState } from '../shell/state';
import { isVertical } from '../shell/layout';

const network = AstalNetwork.get_default();

function sortAccessPoints(accessPoints: Array<AstalNetwork.AccessPoint>) {
  return accessPoints
    .filter((accessPoint) => !!accessPoint.ssid)
    .sort((left, right) => right.strength - left.strength);
}

async function connect(accessPoint: AstalNetwork.AccessPoint) {
  try {
    await execAsync(['nmcli', 'd', 'wifi', 'connect', accessPoint.bssid]);
  } catch (error) {
    console.error(error);
  }
}

export default function Wireless() {
  const wifi = createBinding(network, 'wifi');
  const orientation = createBinding(shellState, 'orientation');

  return (
    <box
      class="rail-module rail-module-wireless"
      visible={wifi(Boolean)}
      halign={orientation((current) =>
        isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
      )}
      hexpand={orientation(isVertical)}
    >
      <With value={wifi}>
        {(currentWifi) =>
          currentWifi && (
            <menubutton
              halign={orientation((current) =>
                isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
              )}
              hexpand={orientation(isVertical)}
            >
              <image iconName={createBinding(currentWifi, 'iconName')} />
              <popover>
                <box
                  class="rail-popover-list"
                  orientation={Gtk.Orientation.VERTICAL}
                  spacing={6}
                >
                  <For each={createBinding(currentWifi, 'accessPoints')(sortAccessPoints)}>
                    {(accessPoint: AstalNetwork.AccessPoint) => (
                      <button onClicked={() => connect(accessPoint)}>
                        <box class="rail-access-point" spacing={8}>
                          <image iconName={createBinding(accessPoint, 'iconName')} />
                          <label hexpand xalign={0} label={createBinding(accessPoint, 'ssid')} />
                          <image
                            iconName="object-select-symbolic"
                            visible={createBinding(currentWifi, 'activeAccessPoint')(
                              (active) => active === accessPoint,
                            )}
                          />
                        </box>
                      </button>
                    )}
                  </For>
                </box>
              </popover>
            </menubutton>
          )
        }
      </With>
    </box>
  );
}
