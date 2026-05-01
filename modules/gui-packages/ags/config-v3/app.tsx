import { createBinding, For, This } from 'ags';
import app from 'ags/gtk4/app';
import style from './style.scss';
import { requestHandler } from './shell/commands';
import RailWindow from './windows/rail-window';

app.start({
  css: style,
  // It's usually best to go with the default Adwaita theme
  // and built off of it, instead of allowing the system theme
  // to potentially mess something up when it is changed.
  // Note: `* { all:unset }` in css is not recommended.
  gtkTheme: 'Adwaita',
  main() {
    const monitors = createBinding(app, 'monitors');

    return (
      <For each={monitors}>
        {(monitor) => (
          <This this={app}>
            <RailWindow gdkmonitor={monitor} />
          </This>
        )}
      </For>
    );
  },
  requestHandler,
});
