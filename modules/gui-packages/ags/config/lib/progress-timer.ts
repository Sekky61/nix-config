import type { AstalIO } from "astal";
import GObject, { property, register, signal } from "astal/gobject";
import { interval } from "astal/time";

@register({ GTypeName: "ProgressTimer" })
class ProgressTimer extends GObject.Object {
  private _timer: AstalIO.Time | null = null;
  private _startTime = 0;
  private _duration = 0;
  private _elapsedBeforePause = 0;
  private _paused = false;

  @property(Number)
  declare progress: number;

  @signal()
  declare done: () => void;

  constructor(params: { duration: number }) {
    super();
    this._duration = params.duration;
  }

  start() {
    this._startTime = Date.now();
    this._elapsedBeforePause = 0;
    this._paused = false;
    this._startTimer();
  }

  private _startTimer() {
    const TICK_MS = 1000 / 60;

    this._timer = interval(TICK_MS);

    this._timer.connect("now", () => {
      const elapsed = Date.now() - this._startTime + this._elapsedBeforePause;

      const progress = Math.min(elapsed / this._duration, 1);
      this.progress = progress;

      if (elapsed >= this._duration) {
        this.cancel();
        this.emit("done");
      }
    });
  }

  pause() {
    if (this._paused || !this._timer) return;

    this._elapsedBeforePause += Date.now() - this._startTime;
    this._paused = true;
    this._timer.cancel();
    this._timer = null;
  }

  unpause() {
    if (!this._paused) return;

    this._startTime = Date.now();
    this._paused = false;
    this._startTimer();
  }

  cancel() {
    if (this._timer) {
      this._timer.cancel();
      this._timer = null;
    }
    this._paused = false;
  }
}

export { ProgressTimer };
