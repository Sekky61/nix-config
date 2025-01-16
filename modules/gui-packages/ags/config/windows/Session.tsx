import { App, Astal, Gdk, Gtk } from "astal/gtk3"
import { execAsync, Variable } from "astal"
import { toggleWindow } from "../util";

type SessionButtonProps = {
    name: string;
    icon: string;
    command: () => void;
    props?: object;
}

const sessionButtons: Record<string, SessionButtonProps> = {
    'lock': { name: 'Lock', icon: 'lock', command: () => { toggleWindow('session'); execAsync('hyprlock') } },
    'logout': { name: 'Logout', icon: 'logout', command: () => { toggleWindow('session'); execAsync(['bash', '-c', 'pkill Hyprland || pkill sway']) } },
    'sleep': { name: 'Sleep', icon: 'sleep', command: () => { toggleWindow('session'); execAsync('systemctl suspend') } },
    'hibernate': { name: 'Hibernate', icon: 'downloading', command: () => { toggleWindow('session'); execAsync('systemctl hibernate') } },
    'shutdown': { name: 'Shutdown', icon: 'power_settings_new', command: () => { toggleWindow('session'); execAsync('systemctl poweroff') } },
    'reboot': { name: 'Reboot', icon: 'restart_alt', command: () => { toggleWindow('session'); execAsync('systemctl reboot') } },
    'cancel': { name: 'Cancel', icon: 'close', command: () => toggleWindow('session'), props: { className: 'session-button-cancel' } },
}

const { CENTER, END } = Gtk.Align

function SessionButton(p: SessionButtonProps) {
    const revealer = <revealer
                        valign={END}
                        transition_type={Gtk.RevealerTransitionType.SLIDE_DOWN}
                        transition_duration={200}>
                        <label label={p.name} className='txt-smaller session-button-desc' />
                    </revealer> as Gtk.Revealer;
    return <button className='session-button' onClick={p.command}
                onFocusInEvent={(self) => revealer.revealChild = true}
                onFocusOutEvent={(self) => revealer.revealChild = false}
                onHover={(self) => {
                    revealer.revealChild = true;
                    const display = Gdk.Display.get_default();
                    if(!display) return;
                    const cursor = Gdk.Cursor.new_from_name(display, 'pointer');
                    self.get_window()?.set_cursor(cursor);
                }}
                onHoverLost={(self) => {
                    revealer.revealChild = false
                    const display = Gdk.Display.get_default();
                    if(!display) return;
                    const cursor = Gdk.Cursor.new_from_name(display, 'default');
                    self.get_window()?.set_cursor(cursor);
                }}
            >
            <overlay overlay={revealer}>
                <label label={p.icon} className='icon-material' vexpand />
            </overlay>
        </button>
}

/** Code can target this window by its name 'session', like `ags toggle 'session'` */
export default function SessionWindow() {

    return <window
        name="session"
        layer={Astal.Layer.OVERLAY}
        exclusivity={Astal.Exclusivity.IGNORE}
        keymode={Astal.Keymode.EXCLUSIVE}
        visible={false}
        application={App}
        onKeyPressEvent={function (self, event: Gdk.Event) {
            if (event.get_keyval()[1] === Gdk.KEY_Escape)
                self.hide()
        }}>
        <box className='session-bg'>
            <box halign={CENTER} vexpand vertical className='spacing-v-15'>
                <label halign={CENTER} label='Use arrow keys to navigate.\nEnter to select, Esc to cancel.' className='txt-small txt' />
                <box valign={CENTER} className='spacing-h-15'>
                    <SessionButton {...sessionButtons['lock']} />
                    <SessionButton {...sessionButtons['logout']} />
                    <SessionButton {...sessionButtons['sleep']} />
                </box>
                <box valign={CENTER} className='spacing-h-15'>
                    <SessionButton {...sessionButtons['hibernate']} />
                    <SessionButton {...sessionButtons['shutdown']} />
                    <SessionButton {...sessionButtons['reboot']} />
                </box>
                <SessionButton {...sessionButtons['cancel']} />
            </box>
        </box>
    </window>
}

