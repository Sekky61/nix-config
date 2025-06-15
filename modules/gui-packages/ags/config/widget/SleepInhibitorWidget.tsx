import type { Binding } from "astal";
import { SleepInhibitor } from "../services/sleep-inhibitor";

interface SleepInhibitorProps {
  vertical: Binding<boolean>;
  children?: JSX.Element | JSX.Element[];
  className?: string;
}

export default function SleepInhibitorWidget({
  vertical,
  children,
  className = "",
}: SleepInhibitorProps) {
  const sleepInhibitor = SleepInhibitor.get_default();
  return (
    <eventbox
      onHover={async () => {
        const success = await sleepInhibitor.inhibitSleep();
        if (!success) {
          console.warn("Failed to inhibit sleep - no available methods");
        }
      }}
      onHoverLost={async () => {
        await sleepInhibitor.uninhibitSleep();
      }}
      className={`${className} mouse-parking`}
    >
      <box
        className={vertical.as(
          (v) => `${v ? "spacing-v-5" : "spacing-h-4"} parking-icon`,
        )}
        vertical={vertical}
      >
        {children}
      </box>
    </eventbox>
  );
}
