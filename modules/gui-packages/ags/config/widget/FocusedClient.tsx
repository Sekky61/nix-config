import { bind } from "astal"
import { Gtk } from "astal/gtk3"
import AstalHyprland from "gi://AstalHyprland"

export default function FocusedClient() {
    const hypr = AstalHyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box
        className="bar-corner-spacing bar-sidemodule bar-space-button"
        vertical
        
        visible={focused.as(Boolean)}>
        <scrollable hscroll={Gtk.PolicyType.AUTOMATIC} vexpand hexpand>
            <box vertical>
                <box className='txt-smallie bar-topdesc txt'>
                    {focused.as(client => (
                        client && <label label={bind(client, "title").as(String)} />
                    ))}
                </box>
                <box className='txt-smaller txt'>
                    {/*Program name*/}
                    {focused.as(client => (
                        client && <label label={bind(client, "class").as(String)} />
                    ))}
                </box>
            </box>
        </scrollable>
    </box>
}
