import { type Binding, GLib, bind } from "astal";
import { interval, map } from "rxjs";
import { bindObservable } from "../util";

export const timeObservable = interval(1000).pipe(
  map((_) => GLib.DateTime.new_now_local()),
);

interface TimeProps {
  vertical: Binding<boolean>;
  horizontalFormat?: string;
}

const timeBind = bindObservable(timeObservable);

// TODO: Unresolved question: why does as() run twice per update?

export default function Time({
  vertical,
  horizontalFormat = "%H:%M - %A %e.",
}: TimeProps) {
  // onDestroy={() => timeBind.drop()}>
  return (
    <box>
      {bind(vertical).as((v) =>
        v ? (
          <box vertical className="spacing-v-5 bar-clock-box">
            <label
              className="txt-onSurfaceVariant"
              label={timeBind.as((t) => t?.format("%H") ?? "E")}
            />
            <label
              className="txt-onSurfaceVariant"
              label={timeBind.as((t) => t?.format("%M") ?? "E")}
            />
          </box>
        ) : (
          <label
            className="spacing-h-5 txt-onSurfaceVariant bar-clock-box"
            label={timeBind.as((t) => t?.format(horizontalFormat) ?? "E")}
          />
        ),
      )}
    </box>
  );
}
