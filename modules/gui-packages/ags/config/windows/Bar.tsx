import { bind, Variable } from "astal";
import { App, Astal, type Gdk, Gtk } from "astal/gtk3";
import type { ChildrenProps } from "../util";
import BatteryLevel from "../widget/BatteryLevel";
import FocusedClient from "../widget/FocusedClient";
import Time from "../widget/Time";
import Tray from "../widget/Tray";
import Workspaces from "../widget/Workspaces";
import SleepInhibitorWidget from "../widget/SleepInhibitorWidget";

export enum BarOrientation {
  HORIZONTAL = "horizontal",
  VERTICAL = "vertical",
  TOGGLE = "toggle",
}

interface BarRequestOptions {
  orientation?: BarOrientation;
}

export function handleBarRequest(options: BarRequestOptions): string {
  if (options.orientation) {
    let newOrientation: BarOrientation = options.orientation;
    if (options.orientation === BarOrientation.TOGGLE) {
      newOrientation =
        barOrientation.get() === BarOrientation.VERTICAL
          ? BarOrientation.HORIZONTAL
          : BarOrientation.VERTICAL;
    }
    barOrientation.set(newOrientation);
    return newOrientation;
  }
  throw new Error(`handleBarRequest: bad request ${JSON.stringify(options)}`);
}

const barOrientation = Variable<BarOrientation>(BarOrientation.VERTICAL);
export const vertical: Variable<boolean> = Variable.derive(
  [barOrientation],
  (bo) => {
    return bo === BarOrientation.VERTICAL;
  },
);

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
  const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;
  const { CENTER, START, END, FILL } = Gtk.Align;
  console.log("Instantiate bar for monitor", gdkmonitor.model);

  return (
    <window
      className="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={bind(vertical).as((ver) =>
        ver ? TOP | BOTTOM | RIGHT : TOP | LEFT | RIGHT,
      )}
      application={App}
    >
      <centerbox
        className="bar-bg"
        orientation={bind(vertical).as((v) =>
          v ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL,
        )}
        vertical={bind(vertical)}
        startWidget={
          <box
            hexpand
            vexpand
            halign={bind(vertical).as((v) => (v ? CENTER : FILL))}
            valign={bind(vertical).as((v) => (v ? START : CENTER))}
          >
            {bind(vertical).as((v) => (v ? <box /> : <FocusedClient />))}
          </box>
        }
        centerWidget={
          <box vertical={bind(vertical)} className="spacing-h-4">
            <BarGroup>
              <Workspaces vertical={bind(vertical)} />
            </BarGroup>
            <BarGroup>
              <BatteryLevel vertical={bind(vertical)} />
            </BarGroup>
          </box>
        }
        endWidget={
          <box
            vertical={bind(vertical)}
            hexpand
            vexpand
            halign={bind(vertical).as((v) => (v ? CENTER : END))}
            valign={bind(vertical).as((v) => (v ? END : CENTER))}
          >
            <BarGroup>
              <box
                vertical={bind(vertical)}
                hexpand
                vexpand
                halign={bind(vertical).as((v) => (v ? CENTER : END))}
                valign={bind(vertical).as((v) => (v ? END : CENTER))}
              >
                <Time vertical={bind(vertical)} />
                <SleepInhibitorWidget vertical={bind(vertical)}>
                  <icon icon="system-suspend" />

                  {bind(vertical).as((v) =>
                    v ? <box /> : <label label="P" />,
                  )}
                </SleepInhibitorWidget>
              </box>
            </BarGroup>
            <Tray vertical={bind(vertical)} />
            <Spacer />
          </box>
        }
      />
    </window>
  );
}

function Spacer() {
  return <box className="bar-sidespace"> </box>;
}
