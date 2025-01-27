import { bind, type Binding } from "astal";
import AstalBattery from "gi://AstalBattery";

interface BatteryProps {
  vertical: Binding<boolean>;
}

export default function BatteryLevel({ vertical }: BatteryProps) {
  const bat = AstalBattery.get_default();

  return (
    <box
      className={vertical.as((v) => `${v ? "spacing-v-5" : "spacing-h-4"} txt-onSurfaceVariant`)}
      vertical={vertical}
      visible={bind(bat, "isPresent")}
    >
      <label
        className="txt-smallie txt-onSurfaceVariant"
        label={bind(bat, "percentage").as((p) => `${Math.floor(p * 100)} %`)}
      />
      <icon className="bar-batt" icon={bind(bat, "batteryIconName")} />
    </box>
  );
}
