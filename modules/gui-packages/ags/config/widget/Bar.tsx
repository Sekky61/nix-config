import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"
import Workspaces from "./Workspaces"
import Tray from "./Tray"
import BatteryLevel from "./BatteryLevel"

const time = Variable("").poll(1000, "date")

export function BarGroup({ child }: {child: JSX.Element}) {
    return <box className='bar-group-margin bar-sides'>
        <box className='bar-group bar-group-standalone bar-group-pad-system'>
            {child}
        </box>
    </box>
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Bar"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}
        application={App}>
        <centerbox
            className="bar-bg"
            centerWidget={
                <box>
                    <BarGroup>
                        <Workspaces />
                    </BarGroup>
                    <BarGroup>
                        <BatteryLevel />
                    </BarGroup>
                </box>
            }
            endWidget={
            <box hexpand halign={Gtk.Align.END}>
                <button
                    onClicked={() => print("hello")}
                    halign={Gtk.Align.CENTER}
                >
                    <label label={time()} />
                </button>
                <Tray />
            </box>
            }
        >
        </centerbox>
    </window>
}
