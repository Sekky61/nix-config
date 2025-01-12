import { bind } from "astal"
import AstalBattery from "gi://AstalBattery"

export default function BatteryLevel() {
    const bat = AstalBattery.get_default()

    return <box className="spacing-h-4 txt-onSurfaceVariant"
        visible={bind(bat, "isPresent")}>
        <label className="txt-smallie txt-onSurfaceVariant" label={bind(bat, "percentage").as(p =>
            `${Math.floor(p * 100)} %`
        )} />
        <icon className="bar-batt" icon={bind(bat, "batteryIconName")} />
    </box>
}
