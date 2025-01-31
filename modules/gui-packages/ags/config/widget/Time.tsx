import { type Binding, GLib, bind } from "astal";
import { interval, map } from "rxjs";
import { fromObservable } from "../util";

export const timeObservable = interval(1000).pipe(
  map((_) => GLib.DateTime.new_now_local()),
);

export const time = fromObservable(
  timeObservable,
  GLib.DateTime.new_now_local(),
);

interface TimeProps {
  vertical: Binding<boolean>;
  horizontalFormat?: string;
}

export default function Time({
  vertical,
  horizontalFormat = "%H:%M - %A %e.",
}: TimeProps) {
  return (
    <box onDestroy={() => time.drop()}>
      {bind(vertical).as((v) =>
        v ? (
          <box vertical className="spacing-v-5 bar-clock-box">
            <label
              className="txt-onSurfaceVariant"
              label={bind(time).as((t) => t.format("%H") ?? "E")}
            />
            <label
              className="txt-onSurfaceVariant"
              label={bind(time).as((t) => t.format("%M") ?? "E")}
            />
          </box>
        ) : (
          <label
            className="spacing-h-5 txt-onSurfaceVariant bar-clock-box"
            label={bind(time).as((t) => t.format(horizontalFormat) ?? "E")}
          />
        ),
      )}
    </box>
  );
}
