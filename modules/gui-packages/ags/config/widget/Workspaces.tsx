import { Gdk, Gtk } from "astal/gtk3";
import { EventBox } from "astal/gtk3/widget";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { debounce, scrollDirection } from "../util";
import { bind, Binding } from "astal";

const hyprland = AstalHyprland.get_default();

const { CENTER, END } = Gtk.Align;

const debouncedWorkspace = debounce((dir: "+1" | "-1") => {
  hyprland.dispatch("workspace", dir);
}, 200);

const idToColor = ["red", "green", "blue"];

/** If there are 2+ monitors, mark the workspace with a color */
function DotFor(monitor: AstalHyprland.Monitor) {
  if (hyprland.monitors.length < 2) return undefined;
  // TODO: eyeballed, might not be reliable
  return (
    <box
      halign={CENTER}
      valign={CENTER}
      css={`color: ${idToColor[monitor.id]}; font-size: 1.8rem;`}
    >
      .
    </box>
  );
}

/** css is defined in _bar.scss */
export default function Workspaces(props: { vertical: boolean | Binding<boolean> }) {

  return (
    <EventBox
      onScroll={(_el, e) => {
        const dir = scrollDirection(e.direction, e.delta_x, e.delta_y);
        if (dir === Gdk.ScrollDirection.RIGHT) {
          debouncedWorkspace(e.time, "+1");
        }
        if (dir === Gdk.ScrollDirection.LEFT) {
          debouncedWorkspace(e.time, "-1");
        }
      }}
    >
      <box vertical={props.vertical} className="">
        {bind(hyprland, "workspaces").as((wss) =>
          wss
            .filter((ws) => !(ws.id >= -99 && ws.id <= -2)) // filter out special workspaces
            .sort((a, b) => a.id - b.id)
            .map((ws) => (
              <overlay overlay={DotFor(ws.monitor)}>
                <button
                  className={bind(hyprland, "focusedWorkspace").as((fw) => {
                    const classes = ["bar-ws"];
                    if (ws === fw) classes.push("bar-ws-active");
                    // if (ws.monitor.name)
                    return classes.join(" ");
                  })}
                  onClicked={() => ws.focus()}
                >
                  {ws.id}
                </button>
              </overlay>
            )),
        )}
      </box>
    </EventBox>
  );
}
