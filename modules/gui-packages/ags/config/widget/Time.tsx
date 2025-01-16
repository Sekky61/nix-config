import { GLib, Variable } from "astal";

export default function Time({ format = "%H:%M - %A %e." }) {
  const time = Variable<string>("").poll(1000, () => GLib.DateTime.new_now_local().format(format)!);

  return (
    <label
      className="spacing-h-5 txt-onSurfaceVariant bar-clock-box"
      onDestroy={() => time.drop()}
      label={time()}
    />
  );
}
