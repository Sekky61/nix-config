import { bind, Variable } from "astal";
import { App, Astal, type Gdk, Gtk } from "astal/gtk3";
import type { ChildrenProps } from "../util";
import BatteryLevel from "../widget/BatteryLevel";
import FocusedClient from "../widget/FocusedClient";
import Time from "../widget/Time";
import Tray from "../widget/Tray";
import Workspaces from "../widget/Workspaces";
import GtkLayerShell from "gi://GtkLayerShell?version=0.1";

export default function Indicator(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;
  const { CENTER, START, END, FILL } = Gtk.Align;

  return (
    <window
      className="indicator"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP}
      application={App}
    >
      <box vertical className="osd-window"></box>
    </window>
  );
}
