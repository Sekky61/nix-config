import { bind, type Binding } from "astal";
import { Astal } from "astal/gtk3";
import AstalBattery from "gi://AstalBattery";
import { sendNotification } from "../lib/notifications";

interface BatteryProps {
  vertical: Binding<boolean>;
}

const BATTERY_WARNINGS = [
  { level: 0.2, title: "Low battery", body: "Plug in the charger" },
  { level: 0.15, title: "Very low battery", body: "You there?" },
  {
    level: 0.05,
    title: "Critical Battery",
    body: "PLUG THE CHARGER ALREADY 😩",
  },
] as const;

/** Notify about low battery levels */
async function lowBatteryMessage() {
  if (bat.charging) return;
  for (let i = nextNotif; i < BATTERY_WARNINGS.length; i++) {
    const warning = BATTERY_WARNINGS[i];
    if (bat.percentage <= warning.level) {
      nextNotif++;
      return sendNotification(warning.title, warning.body, {
        urgency: "critical",
      });
    }
  }
}

const bat = AstalBattery.get_default();
console.log('bat', bat, bat.percentage);
let nextNotif = 0;
bat.connect("notify::percentage", () => {
  lowBatteryMessage();
});
bat.connect("notify::charging", () => {
  nextNotif = 0;
});

// todo make the space before % a short space
export default function BatteryLevel({ vertical }: BatteryProps) {
  return (
    <eventbox
      onClick={(_box, e) => {
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
