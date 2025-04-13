import Wp from "gi://AstalWp";
import { type Binding, bind } from "astal";
import { Gtk } from "astal/gtk3";
import Brightness from "../services/brightness";
import { LevelBar } from "./gtk/LevelBar";
import { IndicatorService, IndicatorTypes } from "../services/indicator";

const { CENTER, END } = Gtk.Align;

type OsdValueProps = {
  name: string;
  valueBind: Binding<number>;
  progressBind: Binding<number>;
  onValueChange: (value: number) => void;
  iconWhenDisabled: string;
};

// OsdValue: name, valueBind, progressBind, iconWhenDisabled, extraProps
function OsdValue({
  name,
  valueBind,
  iconWhenDisabled,
  progressBind,
  onValueChange,
  ...props
}: OsdValueProps) {
  // valueBind: a bindable value (number or string)
  // progressBind: a bindable value (number 0..1)
  // iconWhenDisabled: string/icon to show when disabled

  // If valueBind is not available, show iconWhenDisabled
  const displayValue = valueBind.as((v) =>
    v == null || Number.isNaN(v) ? iconWhenDisabled : `${Math.round(v * 100)}`,
  );
  const progressValue = progressBind.as((v) => (Number.isNaN(v) ? 0 : v));

  return (
    <box vertical hexpand className="osd-bg osd-value" {...props}>
      <box vexpand>
        <label
          xalign={0}
          yalign={0}
          hexpand
          className="osd-label"
          label={name}
        />
        <label hexpand={false} className="osd-value-txt" label={displayValue} />
      </box>
      <slider
        className="osd-slider"
        hexpand
        min={0}
        max={1}
        value={progressValue}
        onDragged={(self) => {
          onValueChange(self.value);
          print("new value", self.value);
        }}
      />
    </box>
  );
}

export default function OsdIndicators() {
  const brightness = Brightness.get_default();
  const brightnessValue = bind(brightness, "screen");
  const defaultSpeaker = Wp.get_default()?.audio.default_speaker;
  if (!defaultSpeaker) throw new Error("OSD: no audio");
  const volumeValue = bind(defaultSpeaker, "volume");

  const brightnessProgress = brightnessValue;
  const volumeProgress = volumeValue;

  const indicatorService = IndicatorService.get_default();
  const selfId = IndicatorTypes.brightnessVolume;

  return (
    <revealer
      transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
      className="osd-show"
      setup={(self) => {
        self.hook(indicatorService, "notify::current-indicator", () => {
          self.revealChild = selfId === indicatorService.currentIndicator;
        });
      }}
    >
      <box halign={CENTER} vertical={false} className="spacing-h--10">
        <OsdValue
          name="Brightness"
          valueBind={brightnessValue}
          progressBind={brightnessProgress}
          onValueChange={(value) => {
            brightness.screen = value;
          }}
          iconWhenDisabled="󰖭"
        />
        <OsdValue
          name="Volume"
          valueBind={volumeValue}
          progressBind={volumeProgress}
          onValueChange={(value) => {
            defaultSpeaker.volume = value;
          }}
          iconWhenDisabled="󰖭"
        />
      </box>
    </revealer>
  );
}
