import { App, Astal, Gdk, Gtk } from "astal/gtk3"
import { execAsync, Variable } from "astal"

type SessionButtonProps = {
    name: string;
    icon: string;
    command: () => void;
    props?: object;
}

const sessionButtons: Record<string, SessionButtonProps> = {
    'lock': { name: 'Lock', icon: 'lock', command: () => { App.closeWindow('session'); execAsync('hyprlock') } },
    'logout': { name: 'Logout', icon: 'logout', command: () => { App.closeWindow('session'); execAsync(['bash', '-c', 'pkill Hyprland || pkill sway']) } },
    'sleep': { name: 'Sleep', icon: 'sleep', command: () => { App.closeWindow('session'); execAsync('systemctl suspend') } },
    'hibernate': { name: 'Hibernate', icon: 'downloading', command: () => { App.closeWindow('session'); execAsync('systemctl hibernate') } },
    'shutdown': { name: 'Shutdown', icon: 'power_settings_new', command: () => { App.closeWindow('session'); execAsync('systemctl poweroff') } },
    'reboot': { name: 'Reboot', icon: 'restart_alt', command: () => { App.closeWindow('session'); execAsync('systemctl reboot') } },
    'cancel': { name: 'Cancel', icon: 'close', command: () => App.closeWindow('session'), props: { className: 'session-button-cancel' } },
}


function SessionButton(p: SessionButtonProps) {
    return <button className='session-button' onClick={p.command}>
        <label label={p.icon} className='icon-material' vexpand />
    </button>
}

/** Code can target this window by its name 'session', like `ags toggle 'session'` */
export default function SessionWindow() {
    const { CENTER } = Gtk.Align

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
            <box halign={CENTER} vexpand vertical>
                <box valign={CENTER}>
                    <SessionButton {...sessionButtons['lock']} />
                    <SessionButton {...sessionButtons['logout']} />
                    <SessionButton {...sessionButtons['sleep']} />
                </box>
                <box valign={CENTER}>
                    <SessionButton {...sessionButtons['hibernate']} />
                    <SessionButton {...sessionButtons['shutdown']} />
                    <SessionButton {...sessionButtons['reboot']} />
                </box>
                <SessionButton {...sessionButtons['cancel']} />
            </box>
        </box>
    </window>
}

