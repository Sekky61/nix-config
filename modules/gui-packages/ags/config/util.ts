import { Binding } from "astal";
import { App, Gdk } from "astal/gtk3";

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

export function scrollDirection(
  dir: Gdk.ScrollDirection,
  dx: number,
  dy: number,
): Gdk.ScrollDirection {
  if (dir === Gdk.ScrollDirection.SMOOTH) {
    if (Math.abs(dx) > Math.abs(dy)) {
      return dx > 0 ? Gdk.ScrollDirection.RIGHT : Gdk.ScrollDirection.LEFT;
    } else {
      return dy > 0 ? Gdk.ScrollDirection.DOWN : Gdk.ScrollDirection.UP;
    }
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
