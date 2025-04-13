import { type ConstructProps, Gtk, astalify } from "astal/gtk3";
import GObject from "gi://GObject";

export class LevelBar extends astalify(Gtk.LevelBar) {
  static {
    GObject.registerClass(this);
  }

  constructor(
    props: ConstructProps<LevelBar, Gtk.LevelBar.ConstructorProps, {}>,
  ) {
    super(props as any);
  }
}
