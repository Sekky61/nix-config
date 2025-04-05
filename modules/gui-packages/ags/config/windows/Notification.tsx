// source: https://github.com/Mabi19/desktop-shell/blob/main/notification-center/notification.tsx

import AstalNotifd from "gi://AstalNotifd";
import { Variable, bind } from "astal";
import type { Binding, Subscribable } from "astal/binding";
import { Astal, type Gtk } from "astal/gtk3";
import { createEnumMap } from "../util";
import { ProgressTimer } from "../lib/progress-timer";

const notifd = AstalNotifd.get_default();

const DEFAULT_TIMEOUT = 4000;

// The purpose if this class is to replace Variable<Array<Widget>>
// with a Map<number, Widget> type in order to track notification widgets
// by their id, while making it conveniently bindable as an array
class NotificationMap implements Subscribable {
  // the underlying map to keep track of id widget pairs
  private map: Map<number, Gtk.Widget> = new Map();

  // it makes sense to use a Variable under the hood and use its
  // reactivity implementation instead of keeping track of subscribers ourselves
  private var: Variable<Array<Gtk.Widget>> = Variable([]);

  // notify subscribers to rerender when state changes
  private notify() {
    this.var.set([...this.map.values()].reverse());
  }

  constructor() {
    /**
     * uncomment this if you want to
     * ignore timeout by senders and enforce our own timeout
     * note that if the notification has any actions
     * they might not work, since the sender already treats them as resolved
     */
    // notifd.ignoreTimeout = true

    notifd.connect("notified", (_, id) => {
      this.set(
        id,
        Notification({
          notification: notifd.get_notification(id),
        }),
      );
    });

    // notifications can be closed by the outside before
    // any user input, which have to be handled too
    notifd.connect("resolved", (_, id) => {
      this.delete(id);
    });
  }

  private set(key: number, value: Gtk.Widget) {
    // in case of replacement destroy previous widget
    this.map.get(key)?.destroy();
    this.map.set(key, value);
    this.notify();
  }

  private delete(key: number) {
    this.map.get(key)?.destroy();
    this.map.delete(key);
    this.notify();
  }

  // needed by the Subscribable interface
  get() {
    return this.var.get();
  }

  // needed by the Subscribable interface
  subscribe(callback: (list: Array<Gtk.Widget>) => void) {
    return this.var.subscribe(callback);
  }
}

export const NotificationPopupWindow = () => {
  const notifs = new NotificationMap();

  return (
    <window
      name="notification-popup-area"
      namespace="notification-popup-area"
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
      layer={Astal.Layer.OVERLAY}
      visible={bind(notifs).as((n) => n.length !== 0)}
    >
      <box
        vertical
        className="osd-notifs spacing-v-5-revealer"
        name="notification-popup-area"
        spacing={12}
        vexpand={false}
      >
        {bind(notifs)}
      </box>
    </window>
  );
};

const NotificationIcon = ({
  notification,
}: {
  notification: AstalNotifd.Notification;
}) => {
  let icon: string | Binding<string> = "dialog-information-symbolic";
  if (notification.image) {
    icon = bind(notification, "image");
  }
  if (notification.appIcon) {
    icon = bind(notification, "appIcon");
  }
  if (notification.desktopEntry) {
    icon = bind(notification, "desktopEntry");
  }
  return <icon icon={icon} className="notif-icon notif-icon-material" />;
};

const urgencyMap = createEnumMap(AstalNotifd.Urgency);

const Notification = ({
  notification,
}: {
  notification: AstalNotifd.Notification;
}) => {
  const timeout =
    notification.expireTimeout === -1
      ? DEFAULT_TIMEOUT
      : notification.expireTimeout;
  const timer = new ProgressTimer({ duration: timeout });
  // const doneHandle = timer.connect("done", () => notification.dismiss());
  timer.start();

  const urgency = urgencyMap[notification.urgency];

  /** Invoke an action by its ID, checking if it exists */
  function handleDefaultClick(_eventBox: unknown, event: Astal.ClickEvent) {
    if (event.button === Astal.MouseButton.PRIMARY) {
      const action = notification
        .get_actions()
        .find((action) => action.id === "default");
      if (action) {
        notification.invoke("default");
      }
    } else if (event.button === Astal.MouseButton.SECONDARY) {
      notification.dismiss();
    }
  }

  return (
    // put the progress bar outside of the padding box so that it can hug the edge
    <eventbox
      onHover={() => timer.pause()}
      onHoverLost={() => timer.unpause()}
      onClick={handleDefaultClick}
      setup={(eb) => {
        // Hook auto disconnects
        eb.hook(timer, "done", () => notification.dismiss());
      }}
    >
      <box vertical={true} vexpand={false} widthRequest={400}>
        <box vertical={true} className={`popup-notif-${urgency}`} spacing={8}>
          <box spacing={8}>
            <circularprogress
              startAt={0.75}
              endAt={0.75}
              value={bind(timer, "progress")}
            >
              <NotificationIcon notification={notification} />
            </circularprogress>
            <label
              label={bind(notification, "summary")}
              className={`txt-smallie notif-body-${urgency}`}
              xalign={0}
            />
            <button onClick={() => notification.dismiss()}>
              <icon icon="window-close-symbolic" />
            </button>
          </box>
          <label
            label={bind(notification, "body")}
            className={`notif-body-${urgency}`}
            useMarkup={true}
            wrap={true}
            xalign={0}
          />

          {notification.get_actions().length > 0 && (
            <box spacing={8} className="notif-actions spacing-h-5">
              {notification.get_actions().map((action) => (
                <button
                  onClick={() => notification.invoke(action.id)}
                  hexpand={true}
                  className={`notif-action notif-action-${urgency}`}
                >
                  {action.label}
                </button>
              ))}
            </box>
          )}
        </box>
      </box>
    </eventbox>
  );
};
