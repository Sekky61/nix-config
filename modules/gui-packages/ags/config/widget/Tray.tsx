import { bind } from "astal";
import AstalTray from "gi://AstalTray?version=0.1";

export default function SysTray() {
  const tray = AstalTray.get_default();

  return (
    <box className="bar-systray">
      {bind(tray, "items").as((items) =>
        items.map((item) => (
          <menubutton
            tooltipMarkup={bind(item, "tooltipMarkup")}
            usePopover={false}
            actionGroup={bind(item, "actionGroup").as((ag) => ["dbusmenu", ag])}
            className="bar-systray-item"
            menuModel={bind(item, "menuModel")}
          >
            <icon gicon={bind(item, "gicon")} />
          </menubutton>
        )),
      )}
    </box>
  );
}
