import { bind, type Binding, GObject, Variable } from "astal";
import { App, Gdk } from "astal/gtk3";
import { BehaviorSubject, type Observer, type Observable } from "rxjs";

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

function hashCode(str: string): number {
  return Array.from(str).reduce(
    (hash, char) => (hash * 31 + char.charCodeAt(0)) | 0,
    0,
  );
}

function uniqueName(obj: object): string {
  const baseName = obj.constructor.name || "Unknown";
  return `${baseName}_${Math.abs(hashCode(JSON.stringify(obj)))}`;
}

/**
 * Turn an RXJS observable to a Gobject emitting a signal.
 * To subscribe, connect to the 'observe' signal.
 *
 * Example:
 * ```
 * const o = new BehaviorSubject(42);
 * const c = observableToGobject(o);
 * const ins = c.get_default();
 * ins.connect("notify::value", (v, w) =>
 *   console.log("notified", v, w),
 * );
 * o.next(43);
 * ```
 */
export function observableToGobject<T>(o: Observable<T>, name?: string) {
  const prop_name = "value";
  return GObject.registerClass(
    {
      GTypeName: name ?? uniqueName(o),
      Properties: {
        value: GObject.ParamSpec.jsobject(
          prop_name,
          "Value",
          "A property holding current Observable value",
          GObject.ParamFlags.READWRITE,
        ),
      },
    },
    class GObs extends GObject.Object {
      static instance: GObs | null;
      static get_default() {
        if (!this.instance) this.instance = new GObs();

        return this.instance;
      }

      #observer: Observer<T>;
      #subscription;
      #value: T | undefined;

      constructor() {
        super();
        this.#observer = {
          next: (v) => {
            this.value = v;
          },
          complete: () => console.info("observer completed"),
          error: (err: any) => console.error("observer error", err),
        };
        this.#subscription = o.subscribe(this.#observer);
      }

      unsubscribe() {
        this.#subscription.unsubscribe();
        GObs.instance = null;
      }

      get value() {
        return this.#value;
      }

      set value(val) {
        // Skip emission if the value has not changed
        if (this.#value === val) return;

        // Set the property value before emitting
        this.#value = val;
        this.notify("value");
      }
    },
  );
}

/**
 * Create a binding for an observable. Use it in jsx.
 * It can have problems if registered multiple times.
 */
export function bindObservable<T>(o: Observable<T>): Binding<T | undefined> {
  const Obj = observableToGobject(o);
  const inst = Obj.get_default();
  return bind(inst, "value");
}

export function scrollDirection(
  dir: Gdk.ScrollDirection,
  dx: number,
  dy: number,
): Gdk.ScrollDirection | null {
  if (dir === Gdk.ScrollDirection.SMOOTH) {
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
