import { Gdk } from "astal/gtk3";
import { EventBox } from "astal/gtk3/widget";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { debounce, scrollDirection } from "../util";

const hyprland = AstalHyprland.get_default();

const debouncedWorkspace = debounce((dir: '+1' | '-1') => {
    hyprland.dispatch("workspace", dir);
}, 200);

export default function Workspaces() {
    return <EventBox
        onClick={(e) => console.log(e)}
        onScroll={(_el, e) => {
            const dir = scrollDirection(e.direction, e.delta_x, e.delta_y);
            console.log(e.x, e.y, e.delta_x, e.delta_y, e.direction, e.modifier, e.time);
            if(dir == Gdk.ScrollDirection.RIGHT) {
                debouncedWorkspace(e.time, '+1');
            }
            if(dir == Gdk.ScrollDirection.LEFT) {
                debouncedWorkspace(e.time, '-1');
            }
        }}
    >
        hihi
    </EventBox>
}
