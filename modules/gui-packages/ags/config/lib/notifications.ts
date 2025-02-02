import { execAsync } from "astal";

type NotifySend = {
  urgency: "low" | "normal" | "critical";
  expireTime: number;
  appName: string;
  icon: string;
  category: string | string[];

  /**
   * If true, the notification is transient and won't be stored in the notification history.
   */
  transient: boolean;

  /**
   * Extra metadata for the notification. Each hint has a type, name, and value.
   * Types can be boolean, int, double, string, byte, or variant.
   */
  hints: {
    type: "boolean" | "int" | "double" | "string" | "byte" | "variant";
    name: string;
    value: string | number | boolean;
  }[];

  /**
   * If true, prints the notification ID to stdout.
   */
  printId: boolean;

  /**
   * Specifies the ID of the notification to replace an existing one.
   */
  replaceId: number;

  /**
   * If true, waits for the notification to be closed before exiting.
   */
  wait: boolean;

  /**
   * Defines interactive actions in the notification. Each action has a name (optional) and a text label.
   */
  actions: { name?: string; text: string }[];
};

export type NotifySendOptions = Partial<NotifySend>;

export function createNotifySendCommand(
  summary: string,
  body?: string,
  options: NotifySendOptions = {},
): string {
  const args: string[] = [];

  if (options.urgency) args.push(`--urgency=${options.urgency}`);
  if (options.expireTime !== undefined)
    args.push(`--expire-time=${options.expireTime}`);
  if (options.appName) args.push(`--app-name="${options.appName}"`);
  if (options.icon) args.push(`--icon="${options.icon}"`);
  if (options.category) {
    const category = Array.isArray(options.category)
      ? options.category.join(",")
      : options.category;
    args.push(`--category="${category}"`);
  }
  if (options.transient) args.push("--transient");
  if (options.hints) {
    options.hints.forEach((hint) => {
      args.push(`--hint=${hint.type}:${hint.name}:${hint.value}`);
    });
  }
  if (options.printId) args.push("--print-id");
  if (options.replaceId !== undefined)
    args.push(`--replace-id=${options.replaceId}`);
  if (options.wait) args.push("--wait");
  if (options.actions) {
    options.actions.forEach((action) => {
      args.push(
        `--action=${action.name ? `${action.name}=${action.text}` : action.text}`,
      );
    });
  }

  const formattedSummary = `"${summary.replace(/"/g, '\\"')}"`;
  const formattedBody = body ? `"${body.replace(/"/g, '\\"')}"` : "";

  return `notify-send ${args.join(" ")} ${formattedSummary} ${formattedBody}`.trim();
}

const defaultOptions: NotifySendOptions = {
  appName: "ags",
};

/** Send notification using `notify-send` */
export async function sendNotification(
  summary: string,
  body?: string,
  options: NotifySendOptions = {},
) {
  const combinedOptions = { ...defaultOptions, ...options };
  return execAsync(createNotifySendCommand(summary, body, combinedOptions));
}
