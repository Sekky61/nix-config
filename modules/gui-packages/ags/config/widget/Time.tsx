import { type Binding, GLib, Variable, bind } from "astal";

interface TimeProps {
  vertical: Binding<boolean>;
  horizontalFormat?: string;
}

export default function Time({
  vertical,
  horizontalFormat = "%H:%M - %A %e.",
}: TimeProps) {
  const time = Variable(GLib.DateTime.new_now_local()).poll(1000, () =>
    GLib.DateTime.new_now_local(),
  );

  return (
    <box onDestroy={() => time.drop()}>
      {bind(vertical).as((v) =>
        v ? (
          <box vertical className="spacing-v-5 bar-clock-box">
            <label
              className="txt-onSurfaceVariant"
              label={bind(time).as((t) => t.format("%H"))}
            />
            <label
              className="txt-onSurfaceVariant"
              label={bind(time).as((t) => t.format("%M"))}
            />
          </box>
        ) : (
          <label
            className="spacing-h-5 txt-onSurfaceVariant bar-clock-box"
            label={bind(time).as((t) => t.format(horizontalFormat))}
          />
        ),
      )}
    </box>
  );
}
