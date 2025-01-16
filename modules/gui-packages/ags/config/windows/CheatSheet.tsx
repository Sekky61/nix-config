import { App, Astal, astalify, ConstructProps, Gtk, Widget } from "astal/gtk3";
import { toggleWindow } from "../util";
import { GLib, GObject, readFile } from "astal";

// Set by a derivation. Relative path ~ does not work
const HOME = GLib.getenv("HOME");
const KEYBIND_JSON_PATH = `${HOME}/.config/keybinds.json`;

type Bind = {
  enable: boolean;
  key: string;
  mods: string[];
  visible: boolean;
};

type Command = {
  dispatcher: string;
  enable: boolean;
  flags: string[];
  params: string;
};

type Keybind = {
  bind: Bind | Bind[];
  command: Command | Command[];
  description: string;
  visible: boolean;
};

// match string with any of supplied words, case insensitive
function anyOf(word: string, ...haystack: string[]) {
  var regex = new RegExp(haystack.join("|"), "i");
  return regex.test(word);
}

// Define category rules with discriminating logic
const categoryRules = {
  screenshot: (keybind: Keybind) => {
    const cmd = getCommand(keybind).params;
    return anyOf(cmd, "grimblast", "wf-recorder", "grim");
  },
  window: (keybind: Keybind) => {
    const dispatcher = getCommand(keybind).dispatcher;
    return anyOf(
      dispatcher,
      "togglefloating",
      "pseudo",
      "killactive",
      "window",
      "togglesplit",
      "move",
      "resize",
    );
  },
  workspace: (keybind: Keybind) => {
    const dispatcher = getCommand(keybind).dispatcher;
    return anyOf(dispatcher, "workspace", "movetoworkspace", "movewindow");
  },
  launch: (keybind: Keybind) => {
    const dispatcher = getCommand(keybind).dispatcher;
    const cmd = getCommand(keybind).params;
    return dispatcher === "exec" && anyOf(cmd, "launch", "open");
  },
  system: (keybind: Keybind) => {
    const cmd = getCommand(keybind).params;
    return anyOf(cmd, "brightnessctl", "hyprlock", "killall");
  },
} as const;

const categories = Object.keys(categoryRules) as Category[];

// Derive category type from rules object
type Category = keyof typeof categoryRules;

class BindsManager {
  private binds: Keybind[];
  private bindsByCategory: Record<Category, Keybind[]>;

  constructor() {
    const str = readFile(KEYBIND_JSON_PATH);
    try {
      this.binds = JSON.parse(str);
    } catch (e) {
      console.error(e);
      this.binds = [];
    }
    this.bindsByCategory = this.categorizeKeybinds();
  }

  getEnabled(): Keybind[] {
    return this.binds.filter((kb) => kb.visible);
  }

  getCategories() {
    return this.bindsByCategory;
  }

  static command(kb: Keybind) {}

  // Function to categorize a single keybind
  categorizeKeybinds() {
    const cats = {} as Record<Category, Keybind[]>;
    for (const cat of categories) {
      cats[cat] = this.keybindsFor(cat);
    }
    return cats;
  }

  keybindsFor(category: Category): Keybind[] {
    const pred = categoryRules[category];
    return this.getEnabled().filter(pred);
  }
}

function getBind(kb: Keybind): Bind {
  return Array.isArray(kb.bind) ? kb.bind[0] : kb.bind;
}

function getCommand(kb: Keybind): Command {
  return Array.isArray(kb.command) ? kb.command[0] : kb.command;
}

const keys = new BindsManager();

const { CENTER } = Gtk.Align;

const clickOutsideToClose = new Widget.EventBox({
  onClick: () => toggleWindow("cheatsheet"),
});

function CheatsheetHeader() {
  return (
    <centerbox
      vertical={false}
      startWidget={<box />}
      centerWidget={
        <box vertical className="spacing-h-15">
          <label label="Cheat Sheet" className="txt-title txt" halign={CENTER} />
        </box>
      }
    />
  );
}

// Grid

class Grid extends astalify(Gtk.Grid) {
  static {
    GObject.registerClass(this);
  }

  constructor(
    props: ConstructProps<
      Grid,
      Gtk.Grid.ConstructorProps,
      {
        onColorSet: [];
      } // signals of Gtk.ColorButton have to be manually typed
    >,
  ) {
    super(props as any);
  }
}

export default function CheatSheet() {
  return (
    <window
      name="cheatsheet"
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      visible={false}
      application={App}
    >
      <box vertical>
        {clickOutsideToClose}
        <box className="cheatsheet-bg spacing-v-15" vertical>
          <CheatsheetHeader />
          <scrollable widthRequest={500} heightRequest={500}>
            <Grid
              columnSpacing={10}
              columnHomogeneous
              setup={(self) => {
                self.insert_column(0);
                self.insert_column(1);
                self.insert_column(2);
                Object.entries(keys.getCategories()).map(([cat, keys], c) => {
                  self.attach(
                    <label label={cat} className="cheatsheet-category-title txt" />,
                    c,
                    0,
                    1,
                    1,
                  );
                  keys.map((kb, r) => {
                    self.attach(
                      <box className="spacing-h-10">
                        <box>
                          {[...getBind(kb).mods, getBind(kb).key].map((k) => (
                            <label label={k} className="cheatsheet-key txt-small" />
                          ))}
                        </box>
                        <label label={kb.description} className="txt chearsheet-action txt-small" />
                      </box>,
                      c,
                      r + 1,
                      1,
                      1,
                    );
                  });
                });
              }}
            />
          </scrollable>
        </box>
      </box>
    </window>
  );
}
