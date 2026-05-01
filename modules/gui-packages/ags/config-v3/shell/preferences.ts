import GLib from 'gi://GLib';
import { DEFAULT_RAIL_ORIENTATION, type RailOrientation, isRailOrientation } from './types';

interface ShellPreferences {
  orientation: RailOrientation;
}

const decoder = new TextDecoder();
const preferencesPath = GLib.build_filenamev([
  GLib.get_user_config_dir(),
  'ags',
  'config-v3',
  'preferences.json',
]);

export function loadPreferences(): ShellPreferences {
  try {
    if (!GLib.file_test(preferencesPath, GLib.FileTest.EXISTS)) {
      return { orientation: DEFAULT_RAIL_ORIENTATION };
    }

    const [, contents] = GLib.file_get_contents(preferencesPath);
    const parsed = JSON.parse(decoder.decode(contents)) as Partial<ShellPreferences>;

    return {
      orientation: isRailOrientation(parsed.orientation)
        ? parsed.orientation
        : DEFAULT_RAIL_ORIENTATION,
    };
  } catch (error) {
    console.error(`Failed to load AGS v3 preferences from ${preferencesPath}`, error);

    return { orientation: DEFAULT_RAIL_ORIENTATION };
  }
}

export function savePreferences(preferences: ShellPreferences) {
  try {
    const directory = GLib.path_get_dirname(preferencesPath);
    GLib.mkdir_with_parents(directory, 0o755);
    GLib.file_set_contents(
      preferencesPath,
      `${JSON.stringify(preferences, null, 2)}\n`,
    );
  } catch (error) {
    console.error(`Failed to save AGS v3 preferences to ${preferencesPath}`, error);
  }
}
