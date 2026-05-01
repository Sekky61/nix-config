import AstalApps from 'gi://AstalApps';
import AstalMpris from 'gi://AstalMpris';
import Gtk from 'gi://Gtk?version=4.0';
import { For, createBinding } from 'ags';
import { shellState } from '../shell/state';
import { isVertical } from '../shell/layout';

const mpris = AstalMpris.get_default();
const apps = new AstalApps.Apps();

export default function MediaIndicator() {
  const players = createBinding(mpris, 'players');
  const orientation = createBinding(shellState, 'orientation');

  return (
    <menubutton
      class="rail-module rail-module-media"
      visible={players((items) => items.length > 0)}
      halign={orientation((current) =>
        isVertical(current) ? Gtk.Align.FILL : Gtk.Align.FILL,
      )}
      hexpand={orientation(isVertical)}
    >
      <box class="rail-media-icons" spacing={6}>
        <For each={players}>
          {(player) => {
            const [app] = apps.exact_query(player.entry);

            return (
              <image
                class="rail-media-app-icon"
                visible={!!app?.iconName}
                iconName={app?.iconName}
              />
            );
          }}
        </For>
      </box>
      <popover>
        <box class="rail-popover-list" spacing={8} orientation={Gtk.Orientation.VERTICAL}>
          <For each={players}>
            {(player) => (
              <box class="rail-media-player" spacing={8}>
                <box class="rail-media-cover">
                  <image pixelSize={52} file={createBinding(player, 'coverArt')} />
                </box>
                <box
                  hexpand
                  valign={Gtk.Align.CENTER}
                  orientation={Gtk.Orientation.VERTICAL}
                  spacing={2}
                >
                  <label xalign={0} label={createBinding(player, 'title')} />
                  <label xalign={0} label={createBinding(player, 'artist')} />
                </box>
                <box spacing={4} valign={Gtk.Align.CENTER}>
                  <button
                    onClicked={() => player.previous()}
                    visible={createBinding(player, 'canGoPrevious')}
                  >
                    <image iconName="media-seek-backward-symbolic" />
                  </button>
                  <button
                    onClicked={() => player.play_pause()}
                    visible={createBinding(player, 'canControl')}
                  >
                    <box>
                      <image
                        iconName="media-playback-start-symbolic"
                        visible={createBinding(player, 'playbackStatus')(
                          (status) => status !== AstalMpris.PlaybackStatus.PLAYING,
                        )}
                      />
                      <image
                        iconName="media-playback-pause-symbolic"
                        visible={createBinding(player, 'playbackStatus')(
                          (status) => status === AstalMpris.PlaybackStatus.PLAYING,
                        )}
                      />
                    </box>
                  </button>
                  <button
                    onClicked={() => player.next()}
                    visible={createBinding(player, 'canGoNext')}
                  >
                    <image iconName="media-seek-forward-symbolic" />
                  </button>
                </box>
              </box>
            )}
          </For>
        </box>
      </popover>
    </menubutton>
  );
}
