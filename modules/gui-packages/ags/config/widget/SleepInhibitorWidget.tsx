import { bind, type Binding } from "astal";
import Gio from "gi://Gio";
import GLib from "gi://GLib";

interface SleepInhibitorProps {
  vertical?: Binding<boolean>;
  children?: JSX.Element | JSX.Element[];
  className?: string;
}

class SleepInhibitor {
  private connection: Gio.DBusConnection | null = null;
  private inhibitCookie: number | null = null;
  private isInhibited = false;
  private fallbackProcess: Gio.Subprocess | null = null;
  private method: "dbus" | "systemd-inhibit" | "xset" | "none" = "none";

  constructor() {
    this.initConnection();
  }

  private async initConnection() {
    // Try to get the session bus connection
    try {
      this.connection = Gio.bus_get_sync(Gio.BusType.SESSION, null);
      console.log("D-Bus session connection established");
    } catch (error) {
      console.error("Failed to connect to session D-Bus:", error);
    }
  }

  private async tryDBusInhibit(): Promise<boolean> {
    if (!this.connection) return false;

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

    for (const service of services) {
      try {
        console.log(`Trying ${service.name}...`);

        if (service.name === "org.freedesktop.login1") {
          const result = await this.callDBusMethod(
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
          );

          if (result) {
            this.inhibitCookie = result.get_child_value(0).get_handle();
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
        console.log(`${service.name} not available:`, error.message);
        continue;
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
    replyType: GLib.VariantType,
  ): Promise<GLib.Variant | null> {
    return new Promise((resolve, reject) => {
      this.connection!.call(
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
            const response = source!.call_finish(result);
            resolve(response);
          } catch (error) {
            reject(error);
          }
        },
      );
    });
  }

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
            const success = source!.wait_finish(result);
            resolve(success);
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
          "--who=Astal Widget",
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

  private async tryXsetInhibit(): Promise<boolean> {
    try {
      // Check if xset is available
      const checkProcess = Gio.Subprocess.new(
        ["which", "xset"],
        Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE,
      );

      const success = await new Promise<boolean>((resolve) => {
        checkProcess.wait_async(null, (source, result) => {
          try {
            const success = source!.wait_finish(result);
            resolve(success);
          } catch {
            resolve(false);
          }
        });
      });

      if (!success) return false;

      // Disable screen saver and DPMS
      const xsetProcess = Gio.Subprocess.new(
        ["xset", "s", "off", "-dpms"],
        Gio.SubprocessFlags.NONE,
      );

      await new Promise<void>((resolve) => {
        xsetProcess.wait_async(null, () => resolve());
      });

      this.method = "xset";
      return true;
    } catch (error) {
      console.error("xset failed:", error);
      return false;
    }
  }

  async inhibitSleep(): Promise<boolean> {
    if (this.isInhibited) return true;

    console.log("Attempting to inhibit sleep...");

    // Try D-Bus methods first
    if (await this.tryDBusInhibit()) {
      this.isInhibited = true;
      console.log(`Sleep inhibited via D-Bus (${this.method})`);
      return true;
    }

    // Fallback to systemd-inhibit
    if (await this.trySystemdInhibit()) {
      this.isInhibited = true;
      console.log("Sleep inhibited via systemd-inhibit");
      return true;
    }

    // Fallback to xset
    if (await this.tryXsetInhibit()) {
      this.isInhibited = true;
      console.log("Sleep inhibited via xset");
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

        case "xset":
          // Re-enable screen saver and DPMS
          const xsetProcess = Gio.Subprocess.new(
            ["xset", "s", "on", "+dpms"],
            Gio.SubprocessFlags.NONE,
          );
          await new Promise<void>((resolve) => {
            xsetProcess.wait_async(null, () => resolve());
          });
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

// Create a singleton instance
const sleepInhibitor = new SleepInhibitor();

export default function SleepInhibitorWidget({
  vertical = bind(false),
  children,
  className = "",
}: SleepInhibitorProps) {
  return (
    <eventbox
      onHover={async () => {
        const success = await sleepInhibitor.inhibitSleep();
        if (!success) {
          console.warn("Failed to inhibit sleep - no available methods");
        }
      }}
      onHoverLost={async () => {
        await sleepInhibitor.uninhibitSleep();
      }}
      className={`${className} mouse-parking`}
    >
      <box
        className={vertical.as(
          (v) => `${v ? "spacing-v-5" : "spacing-h-4"} parking-icon`,
        )}
        vertical={vertical}
      >
        {children}
      </box>
    </eventbox>
  );
}

// Usage example with status indicator:
export function SleepInhibitorWithStatus() {
  return (
    <SleepInhibitorWidget>
      <icon
        icon={bind(sleepInhibitor.getStatus().inhibited).as((inhibited) =>
          inhibited ? "caffeine-on" : "caffeine-off",
        )}
      />
      <label
        label={bind(sleepInhibitor.getStatus().method).as((method) =>
          method === "none" ? "Hover to prevent sleep" : `Active (${method})`,
        )}
      />
    </SleepInhibitorWidget>
  );
}
