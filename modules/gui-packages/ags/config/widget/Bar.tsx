import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"
import Workspaces from "./Workspaces"
import Tray from "./Tray"
import BatteryLevel from "./BatteryLevel"
import type { ChildrenProps } from "../util"
import FocusedClient from "./FocusedClient"

const time = Variable("").poll(1000, "date")

/** Wrap a component in colored bubble */
export function BarGroup({ child, children }: ChildrenProps) {
    return <box className='bar-group-margin bar-sides'>
        <box className='bar-group bar-group-standalone bar-group-pad-system'>
            {child}
            {children}
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
            startWidget={
                <FocusedClient />
            }
            centerWidget={
                <box className='spacing-h-4'>
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
