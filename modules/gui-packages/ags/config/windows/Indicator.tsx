import { App, Astal, type Gdk, Gtk } from "astal/gtk3";

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
