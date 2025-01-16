import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import Workspaces from "../widget/Workspaces";
import Tray from "../widget/Tray";
import BatteryLevel from "../widget/BatteryLevel";
import type { ChildrenProps } from "../util";
import FocusedClient from "../widget/FocusedClient";
import Time from "../widget/Time";

/** Wrap a component in colored bubble */
export function BarGroup({ child, children }: ChildrenProps) {
  return (
    <box className="bar-group-margin bar-sides">
      <box className="bar-group bar-group-standalone bar-group-pad">
        {child}
        {children}
      </box>
    </box>
  );
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      className="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox
        className="bar-bg"
        startWidget={<FocusedClient />}
        centerWidget={
          <box className="spacing-h-4">
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
            <BarGroup>
              <Time />
            </BarGroup>
            <Tray />
          </box>
        }
      ></centerbox>
    </window>
  );
}
