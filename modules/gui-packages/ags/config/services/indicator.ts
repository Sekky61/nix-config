import GObject, { register, property } from "astal/gobject";
import Wp from "gi://AstalWp";
import { type Time, timeout } from "astal/time";

export const IndicatorTypes = {
  brightnessVolume: "brightnessVolume",
} as const;

type IndicatorType = keyof typeof IndicatorTypes;

function isIndicatorType(string: string): string is IndicatorType {
  return Object.keys(IndicatorTypes).includes(string);
}

export type PopupRequestOptions = {
  args: string[];
};

@register({ GTypeName: "IndicatorService" })
export class IndicatorService extends GObject.Object {
  static instance: IndicatorService;
  static get_default() {
    if (!this.instance) this.instance = new IndicatorService();

    return this.instance;
  }

  @property(String)
  declare currentIndicator: IndicatorType | null;

  #timeoutId: Time | null = null;
  #defaultTimeoutMs = 1500;

  // Show an indicator of a given type for a timeout (ms)
  show(type: IndicatorType, timeoutMs?: number) {
    this.currentIndicator = type;
    if (this.#timeoutId) {
      this.#timeoutId.cancel();
      this.#timeoutId = null;
    }
    this.#timeoutId = timeout(timeoutMs ?? this.#defaultTimeoutMs, () =>
      this.hide(),
    );
  }

  // Hide the indicator
  hide() {
    this.currentIndicator = null;
    if (this.#timeoutId) {
      this.#timeoutId.cancel();
      this.#timeoutId = null;
    }
  }

  /**
   * Usage: `ags request "show-popup brightnessVolume"`
   */
  handlePopupRequest({ args }: PopupRequestOptions): string {
    if (args.length < 2) {
      return "Expected at least one argument (indicatorType)";
    }
    const type = args[1];
    if (!isIndicatorType(type)) {
      return `Unknown indicatorType: ${type}`;
    }
    this.show(type);
    return type;
  }

  constructor() {
    super();

    const defaultSpeaker = Wp.get_default()?.audio.default_speaker;
    if (defaultSpeaker) {
      const id = defaultSpeaker.connect("notify::volume", () => {
        this.show(IndicatorTypes.brightnessVolume);
      });
    }
  }
}
