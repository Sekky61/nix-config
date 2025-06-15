import { GObject, register } from "astal";
import Gio from "gi://Gio";
import GLib from "gi://GLib";

@register({ GTypeName: "SleepInhibitor" })
export class SleepInhibitor extends GObject.Object {
  static instance: SleepInhibitor;
  static get_default() {
    if (!this.instance) this.instance = new SleepInhibitor();

    return this.instance;
  }

  private connection: Gio.DBusConnection | null = null;
  private inhibitCookie: number | null = null;
  private isInhibited = false;
  private fallbackProcess: Gio.Subprocess | null = null;
  private method: "dbus" | "systemd-inhibit" | "none" = "none";

  constructor() {
    super();
    this.connection = Gio.DBus.session;
  }

  private async tryDBusInhibit(): Promise<boolean> {
    if (!this.connection) return false;

    for (const service of services) {
      try {
        console.log(`Trying ${service.name}...`);

        if (service.name === "org.freedesktop.login1") {
          // todo: service exists and probably inhibits, but I cannot read if it blocks
          const result = await this.connection?.call(
            service.name,
            service.path,
            service.interface,
            "Inhibit",
            new GLib.Variant("(ssss)", [
              "sleep:idle",
              "Astal Widget",
              "User interaction",
              "block",
            ]),
            new GLib.VariantType("(h)"),
            Gio.DBusCallFlags.NONE,
            -1,
            null,
            // null,
          );
          console.log(result);

          if (result) {
            this.inhibitCookie = result.get_child_value(0).get_handle();
            console.log("cookie", this.inhibitCookie);
            this.method = "dbus";
            return true;
          }
        } else if (service.name === "org.gnome.SessionManager") {
          const result = await this.callDBusMethod(
            service.name,
            service.path,
            service.interface,
            "Inhibit",
            new GLib.Variant("(susu)", [
              "Astal Widget",
              0,
              "User interaction",
              8, // Inhibit idle
            ]),
            new GLib.VariantType("(u)"),
          );

          if (result) {
            this.inhibitCookie = result.get_child_value(0).get_uint32();
            this.method = "dbus";
            return true;
          }
        }
      } catch (error) {
        console.log(
          `${service.name} not available:`,
          (error as Error)?.message,
        );
      }
    }

    return false;
  }

  private async callDBusMethod(
    serviceName: string,
    objectPath: string,
    interfaceName: string,
    methodName: string,
    parameters: GLib.Variant,
    replyType: GLib.VariantType | null,
  ): Promise<GLib.Variant | null> {
    return new Promise((resolve, reject) => {
      this.connection?.call(
        serviceName,
        objectPath,
        interfaceName,
        methodName,
        parameters,
        replyType,
        Gio.DBusCallFlags.NONE,
        5000, // 5 second timeout
        null,
        (source, result) => {
          try {
            const response = source?.call_finish(result);
            if (response) {
              resolve(response);
            }
          } catch (error) {
            reject(error);
          }
        },
      );
    });
  }

  /**
   * Spawns a process and as long as the process lives, sleep is inhibited.
   */
  private async trySystemdInhibit(): Promise<boolean> {
    try {
      // Check if systemd-inhibit is available
      const checkProcess = Gio.Subprocess.new(
        ["which", "systemd-inhibit"],
        Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE,
      );

      const success = await new Promise<boolean>((resolve) => {
        checkProcess.wait_async(null, (source, result) => {
          try {
            const success = source?.wait_finish(result);
            if (success) {
              resolve(success);
            }
          } catch {
            resolve(false);
          }
        });
      });

      if (!success) return false;

      this.fallbackProcess = Gio.Subprocess.new(
        [
          "systemd-inhibit",
          "--what=sleep:idle",
          "--who=SleepInhibitor Service",
          "--why=User interaction",
          "sleep",
          "infinity",
        ],
        Gio.SubprocessFlags.NONE,
      );

      this.method = "systemd-inhibit";
      return true;
    } catch (error) {
      console.error("systemd-inhibit failed:", error);
      return false;
    }
  }

  async inhibitSleep(): Promise<boolean> {
    if (this.isInhibited) return true;

    // if (await this.tryDBusInhibit()) {
    //   this.isInhibited = true;
    //   console.log(`Sleep inhibited via D-Bus (${this.method})`);
    //   return true;
    // }

    if (await this.trySystemdInhibit()) {
      this.isInhibited = true;
      console.log("Sleep inhibited via systemd-inhibit");
      return true;
    }

    console.error("All sleep inhibition methods failed");
    return false;
  }

  async uninhibitSleep(): Promise<boolean> {
    if (!this.isInhibited) return true;

    try {
      switch (this.method) {
        case "dbus":
          if (this.inhibitCookie !== null) {
            // For login1, close the file descriptor
            if (
              typeof this.inhibitCookie === "number" &&
              this.inhibitCookie > 0
            ) {
              GLib.close(this.inhibitCookie);
            }
            // For GNOME Session Manager, call Uninhibit
            else {
              await this.callDBusMethod(
                "org.gnome.SessionManager",
                "/org/gnome/SessionManager",
                "org.gnome.SessionManager",
                "Uninhibit",
                new GLib.Variant("(u)", [this.inhibitCookie]),
                null,
              );
            }
          }
          break;

        case "systemd-inhibit":
          if (this.fallbackProcess) {
            this.fallbackProcess.force_exit();
            this.fallbackProcess = null;
          }
          break;
      }

      this.isInhibited = false;
      this.inhibitCookie = null;
      this.method = "none";
      console.log("Sleep inhibition released");
      return true;
    } catch (error) {
      console.error("Failed to uninhibit sleep:", error);
      return false;
    }
  }

  getStatus(): { inhibited: boolean; method: string } {
    return { inhibited: this.isInhibited, method: this.method };
  }
}

const services = [
  {
    name: "org.freedesktop.login1",
    path: "/org/freedesktop/login1",
    interface: "org.freedesktop.login1.Manager",
  },
  {
    name: "org.gnome.SessionManager",
    path: "/org/gnome/SessionManager",
    interface: "org.gnome.SessionManager",
  },
  {
    name: "org.freedesktop.PowerManagement.Inhibit",
    path: "/org/freedesktop/PowerManagement/Inhibit",
    interface: "org.freedesktop.PowerManagement.Inhibit",
  },
];
