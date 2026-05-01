import Astal from 'gi://Astal?version=4.0';
import Gtk from 'gi://Gtk?version=4.0';
import type { RailOrientation } from './types';

export function isVertical(orientation: RailOrientation) {
  return orientation === 'vertical';
}

export function getWindowAnchor(orientation: RailOrientation) {
  const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;

  return isVertical(orientation) ? TOP | BOTTOM | RIGHT : TOP | LEFT | RIGHT;
}

export function getGtkOrientation(orientation: RailOrientation) {
  return isVertical(orientation) ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL;
}
