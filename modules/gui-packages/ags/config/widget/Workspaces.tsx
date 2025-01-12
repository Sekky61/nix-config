import { Gdk } from "astal/gtk3";
import { EventBox } from "astal/gtk3/widget";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { debounce, scrollDirection } from "../util";
import { bind, Binding, Variable } from "astal";

const hyprland = AstalHyprland.get_default();

const debouncedWorkspace = debounce((dir: '+1' | '-1') => {
    hyprland.dispatch("workspace", dir);
}, 200);

/**
 * Workspaces bar. Shows them separated by monitors.
 */
function WorkspaceContents(count: number) {
    const ws = bind(hyprland, 'workspaces');
    const focusedWs = bind(hyprland, 'focusedWorkspace');

    // Monitor ids should start with 0
    const perId = Variable.derive([ws], (ws) => {
        return ws.reduce((acc, w) => {
            const mid = w.id;
            acc[mid] = w;
            return acc;
        }, {} as Partial<Record<number, AstalHyprland.Workspace>>) ;
    });

    return Array.from({ length: count }, (_, i) => i).map((_, index) => {
        const wsId = index + 1;
        return <box>
            <label
                setup={(self) => {
                    self.toggleClassName('bar-ws-occupied', perId(o => o[wsId] !== undefined).get());
                    self.hook(perId, (self) => {
                        // Does not fire on first render, so is also set in setup
                        self.toggleClassName('bar-ws-occupied', perId.get()[wsId] !== undefined);
                    });
                    self.hook(focusedWs, (_self) => {
                        self.toggleClassName('bar-ws-active', focusedWs.get().id === wsId);
                    });
                }}
                className="bar-ws"
                label={wsId.toString()} />
        </box>
    });
}

/** css is defined in _bar.scss */
export default function Workspaces() {
    return <EventBox
        onClick={(e) => console.log(e)}
        className="bar-group bar-group-standalone bar-group-pad bar-ws-width"
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
        <box>
            {WorkspaceContents(12)}
        </box>
    </EventBox>
}
