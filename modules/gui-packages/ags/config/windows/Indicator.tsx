import { App, Astal, type Gdk, Gtk } from "astal/gtk3";
import OsdIndicators from "../widget/Indicator";

export default function Indicator() {
  const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;
  const { CENTER, START, END, FILL } = Gtk.Align;

  return (
    <window
      name="indicator"
      namespace="indicator-area"
      anchor={TOP}
      layer={Astal.Layer.OVERLAY}
      visible={true}
    >
      <box vertical className="osd-window">
        <OsdIndicators />
      </box>
    </window>
  );
}
