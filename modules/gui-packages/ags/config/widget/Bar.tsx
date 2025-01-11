import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"
import Workspaces from "./Workspaces"

const time = Variable("").poll(1000, "date")

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Bar"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}
        application={App}>
        <centerbox>
            <Workspaces />
            <button
                onClicked="echo hello"
                halign={Gtk.Align.CENTER}
                className="btn-primary"
            >
                Welcome to AGS!
            </button>
            <box />
            <button
                onClicked={() => print("hello")}
                halign={Gtk.Align.CENTER}
            >
                <label label={time()} />
            </button>
        </centerbox>
    </window>
}
