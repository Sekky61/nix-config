import { bind } from "astal";
import AstalTray from "gi://AstalTray?version=0.1";

const tray = AstalTray.get_default();

function SysTrayItem(item: AstalTray.TrayItem) {
    console.log('item', item, item.to_json_string());
    return (
        <button className='bar-systray-item'>
            <icon gicon={bind(item, 'gicon') || "missing-symbolic"} />
            g
        </button>
    );
}

// export default function Tray() {
//     return (
//         <box className='margin-right-5 spacing-h-15'>
//             {bind(tray, 'items').as(items => {
//                 console.log('items', items);
//                 items.map(SysTrayItem)
//             })
//             }
//         </box>
//             );
// }

export default function SysTray() {
    const tray = AstalTray.get_default()

    return <box className="bar-systray">
        {bind(tray, "items").as(items => items.map(item => (
            <menubutton
                tooltipMarkup={bind(item, "tooltipMarkup")}
                usePopover={false}
                actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
                className='bar-systray-item'
                menuModel={bind(item, "menuModel")}>
                <icon gicon={bind(item, "gicon")} />
            </menubutton>
        )))}
    </box>
}
