import { type Binding, GLib, Variable, bind } from "astal";

interface TimeProps {
  vertical: Binding<boolean>;
  horizontalFormat?: string;
}

// TODO: Unresolved question: why does as() run twice per update?

export default function Time({
  vertical,
  horizontalFormat = "%H:%M - %A %e.",
}: TimeProps) {
  const time = Variable<GLib.DateTime | undefined>(undefined).poll(1000, () =>
    GLib.DateTime.new_now_local(),
  );
  return (
    <box>
      {bind(vertical).as((v) =>
        v ? (
          <box vertical className="spacing-v-5 bar-clock-box">
            <label
              className="txt-onSurfaceVariant"
              label={bind(time).as((t) => t?.format("%H") ?? "E")}
            />
            <label
              className="txt-onSurfaceVariant"
              label={bind(time).as((t) => t?.format("%M") ?? "E")}
            />
          </box>
        ) : (
          <label
            className="spacing-h-5 txt-onSurfaceVariant bar-clock-box"
            label={bind(time).as((t) => t?.format(horizontalFormat) ?? "E")}
          />
        ),
      )}
    </box>
  );
}
