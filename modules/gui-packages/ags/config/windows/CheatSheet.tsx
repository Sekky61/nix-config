import { GLib, GObject, Variable, bind, readFile } from "astal";
import {
  App,
  Astal,
  type ConstructProps,
  Gtk,
  Widget,
  astalify,
} from "astal/gtk3";
import { toggleWindow } from "../util";

// Set by a derivation. Relative path ~ does not work
const HOME = GLib.getenv("HOME");
const KEYBIND_JSON_PATH = `${HOME}/.config/keybinds.json`;

// Variable controlling displayed category
const activeCategory = Variable<Category>("window");

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
  const regex = new RegExp(haystack.join("|"), "i");
  return regex.test(word);
}

// Define category rules with discriminating logic
const categoryRules = {
  screenshot: (keybind: Keybind) => {
    const cmd = getCommand(keybind).params;
    return anyOf(
      cmd,
      "record",
      "hyprshot",
      "grimblast",
      "wf-recorder",
      "grim",
      "hyprpicker",
    );
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
      "fullscreen", // "fullscreenstate",
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
    return (
      (dispatcher === "exec" && anyOf(cmd, "launch", "open", "fuzzel")) ||
      anyOf(keybind.description, "Launch")
    );
  },
  system: (keybind: Keybind) => {
    const cmd = getCommand(keybind).params;
    return (
      anyOf(cmd, "brightnessctl", "hyprlock", "killall") ||
      anyOf(keybind.description, "volume", "track", "media", "monitor")
    );
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
      vertical={true}
      centerWidget={
        <box vertical className="spacing-h-15">
          <label
            label="Cheat Sheet"
            className="txt-title txt"
            halign={CENTER}
          />
        </box>
      }
    />
  );
}

/** A single key, with border and special rendering of super key */
function Key(props: { child: string }) {
  const key = props?.child ?? "?";
  const renderedKey = key.toLowerCase() === "super" ? "" : key;
  return <label label={renderedKey} className="cheatsheet-key txt-small" />;
}

interface KeyCategoryProps {
  name: string;
  keybinds: Keybind[];
}

function KeyCategory({ name, keybinds }: KeyCategoryProps) {
  // Name on top level box is for stack
  return (
    <scrollable heightRequest={500}>
      <box
        vertical
        className="cheatsheet-category-container spacing-v-10"
        name={name}
      >
        <label label={name} className="cheatsheet-category-title txt" />
        {keybinds.map((kb) => (
          <box className="spacing-h-10">
            <box>
              {[...getBind(kb).mods, getBind(kb).key].map((k) => (
                <Key>{k}</Key>
              ))}
            </box>
            <label
              label={kb.description}
              className="txt chearsheet-action txt-small"
            />
          </box>
        ))}
      </box>
    </scrollable>
  );
}

// subclass, register, define constructor props
class StackSwitcher extends astalify(Gtk.StackSwitcher) {
  static {
    GObject.registerClass(this);
  }

  constructor(
    props: ConstructProps<
      StackSwitcher,
      Gtk.StackSwitcher.ConstructorProps,
      {} // signals of Gtk.StackSwitcher have to be manually typed
    >,
  ) {
    super(props as any);
  }
}

export default function CheatSheet() {
  const stack = (
    <stack
      visibleChildName={bind(activeCategory)}
      setup={(st) => {
        Object.entries(keys.getCategories()).map(([catName, keys]) =>
          // Needs add_titled, not just children
          st.add_titled(
            <KeyCategory name={catName} keybinds={keys} />,
            catName,
            catName,
          ),
        );
      }}
    />
  ) as Gtk.Stack;
  // todo cannot style the stackswitcher buttons

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
          <StackSwitcher className="spacing-h-10" stack={stack} />
          {stack}
        </box>
      </box>
    </window>
  );
}
