import GObject from 'gi://GObject';
import { loadPreferences, savePreferences } from './preferences';
import { DEFAULT_RAIL_ORIENTATION, type RailOrientation } from './types';

class ShellState extends GObject.Object {
  static instance: ShellState | null = null;

  static get_default() {
    if (!this.instance) {
      this.instance = new this();
    }

    return this.instance;
  }

  declare orientation: RailOrientation;

  constructor() {
    super();

    this.orientation = loadPreferences().orientation;
  }

  setOrientation(nextOrientation: RailOrientation) {
    if (this.orientation === nextOrientation) {
      return this.orientation;
    }

    this.orientation = nextOrientation;
    savePreferences({ orientation: this.orientation });

    return this.orientation;
  }

  toggleOrientation() {
    return this.setOrientation(
      this.orientation === 'vertical' ? 'horizontal' : 'vertical',
    );
  }
}

const ShellStateClass = GObject.registerClass({
  GTypeName: 'AgsConfigV3ShellState',
  Properties: {
    orientation: GObject.ParamSpec.string(
      'orientation',
      'Orientation',
      'Current rail orientation',
      GObject.ParamFlags.READWRITE,
      DEFAULT_RAIL_ORIENTATION,
    ),
  },
}, ShellState);

const shellState = ShellStateClass.get_default();

export { shellState };

export function setRailOrientation(orientation: RailOrientation) {
  return shellState.setOrientation(orientation);
}

export function toggleRailOrientation() {
  return shellState.toggleOrientation();
}
