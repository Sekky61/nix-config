import { bind, type Binding } from "astal";
import { Astal } from "astal/gtk3";
import AstalBattery from "gi://AstalBattery";
import { sendNotification } from "../lib/notifications";

interface BatteryProps {
  vertical: Binding<boolean>;
}

const BATTERY_WARNINGS = [
  {
    level: 0.05,
    title: "Critical Battery",
    body: "PLUG THE CHARGER ALREADY 😩",
  },
  { level: 0.15, title: "Very low battery", body: "You there?" },
  { level: 0.2, title: "Low battery", body: "Plug in the charger" },
] as const;

/** Notify about low battery levels */
async function lowBatteryMessage() {
  if (bat.charging) return;
  for (const warning of BATTERY_WARNINGS) {
    if (bat.percentage <= warning.level && bat.percentage < (notifiedAt ?? 1)) {
      notifiedAt = warning.level;
      return sendNotification(warning.title, warning.body, {
        urgency: "critical",
      });
    }
  }
}

const bat = AstalBattery.get_default();
let notifiedAt: number | null = null;
bat.connect("notify::percentage", (d, v) => {
  lowBatteryMessage();
});
bat.connect("notify::charging", (d, v) => {
  notifiedAt = null;
});

export default function BatteryLevel({ vertical }: BatteryProps) {
  return (
    <eventbox
      onClick={(box, e) => {
        console.log("click", box, e);
        if (e.button === Astal.MouseButton.PRIMARY) {
          sendNotification(
            `Battery is at ${Math.floor(bat.percentage * 100)}%`,
          );
        }
      }}
    >
      <box
        className={vertical.as(
          (v) => `${v ? "spacing-v-5" : "spacing-h-4"} txt-onSurfaceVariant`,
        )}
        vertical={vertical}
        visible={bind(bat, "isPresent")}
      >
        <label
          className="txt-smallie txt-onSurfaceVariant"
          label={bind(bat, "percentage").as((p) => `${Math.floor(p * 100)} %`)}
        />
        <icon className="bar-batt" icon={bind(bat, "batteryIconName")} />
      </box>
    </eventbox>
  );
}
