import { type Binding, Variable } from "astal";
import { App, Gdk } from "astal/gtk3";
import { BehaviorSubject, type Observable } from "rxjs";

/** Composable interface for child/children quirk that TS has problem with */
export interface ChildrenProps {
  child?: JSX.Element | Binding<JSX.Element> | Binding<Array<JSX.Element>>;
  children?: Array<JSX.Element> | Binding<Array<JSX.Element>>;
}

/** Toggle visibility of a window by name */
export function toggleWindow(windowName: string) {
  const foundWindow = App.get_window(windowName);

  if (!foundWindow) {
    return;
  }

  foundWindow.set_visible(!foundWindow.visible);
}

export function fromObservable<T>(o: Observable<T>): Variable<T | null>;
export function fromObservable<T>(
  o: Observable<T>,
  initialValue: T,
): Variable<T>;
export function fromObservable<T>(o: BehaviorSubject<T>): Variable<T>;
export function fromObservable<T>(...args: unknown[]): unknown {
  const o = args[0] as Observable<T>;
  let v: Variable<T | null>;
  if (o && o instanceof BehaviorSubject) {
    v = Variable<T>(o.value);
  } else if (args[1]) {
    v = Variable<T>(args[1] as T);
  } else {
    v = Variable<T | null>(null);
  }
  o.subscribe({
    next: (val) => v.set(val),
    error: (err) => {
      console.error("observable error:", err);
      v.drop();
    },
    complete: () => {
      console.info("observable complete");
    },
  });
  return v;
}

export function scrollDirection(
  dir: Gdk.ScrollDirection,
  dx: number,
  dy: number,
): Gdk.ScrollDirection | null {
  if (dir === Gdk.ScrollDirection.SMOOTH) {
    console.log(dx, dy);
    const absx = Math.abs(dx);
    const absy = Math.abs(dy);
    if (Math.max(absx, absy) < 0.03) return null;
    if (absx > absy) {
      return dx > 0 ? Gdk.ScrollDirection.RIGHT : Gdk.ScrollDirection.LEFT;
    }
    return dy > 0 ? Gdk.ScrollDirection.DOWN : Gdk.ScrollDirection.UP;
  }
  return dir;
}

/**
 * Creates a debounced function that limits the execution of the provided function
 * to at most once per specified interval (in milliseconds).
 *
 * @param func - The function to debounce.
 * @param wait - The minimum delay between executions, in milliseconds.
 * @returns The debounced function.
 */
export function debounce<T extends (...args: any[]) => void>(
  func: T,
  wait: number,
): (time: number, ...args: Parameters<T>) => void {
  let lastCall = 0;

  return function (time, ...args: Parameters<T>) {
    if (time - lastCall >= wait) {
      lastCall = time;
      func(...args);
    }
  };
}
