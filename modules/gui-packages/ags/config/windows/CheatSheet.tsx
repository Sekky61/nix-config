import { App, Astal, Gtk, Widget } from "astal/gtk3"
import { toggleWindow } from "../util";
import { GLib, readFile } from "astal";

// Set by a derivation. Relative path ~ does not work
const HOME = GLib.getenv("HOME")
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

type KeyConfig = Keybind[];

class KeyConfigManager {
  private config: KeyConfig;

  constructor() {
    const str = readFile(KEYBIND_JSON_PATH);
    try {
        this.config = JSON.parse(str);
    } catch (e) {
        console.error(e);
        this.config = [];
    }
  }

  getEnabled(): Keybind[] {
    return this.config.filter(kb => kb.visible);
  }

  // get all keybinds, flattening Bind or Bind[] to Bind[]
  getAllBinds(): Bind[] {
    return this.config.flatMap((keybind) =>
      Array.isArray(keybind.bind) ? keybind.bind : [keybind.bind]
    );
  }

  // get all commands, flattening Command or Command[] to Command[]
  getAllCommands(): Command[] {
    return this.config.flatMap((keybind) =>
      Array.isArray(keybind.command) ? keybind.command : [keybind.command]
    );
  }
}

function getBind(kb: Keybind): Bind {
    return Array.isArray(kb.bind) ? kb.bind[0] : kb.bind;
}

const keys = new KeyConfigManager();

const { CENTER } = Gtk.Align;

const clickOutsideToClose = new Widget.EventBox({
    onClick: () => toggleWindow('cheatsheet'),
});

function CheatsheetHeader() {
    return <centerbox vertical={false}
        startWidget={<box />}
        centerWidget={<box vertical className='spacing-h-15'>
            <label label='Cheat Sheet' className='txt-title txt' halign={CENTER} />
        </box>}
    >
    </centerbox>;
}

export default function CheatSheet() {
    console.dir(keys);

    return <window
        name="cheatsheet"
        layer={Astal.Layer.OVERLAY}
        exclusivity={Astal.Exclusivity.IGNORE}
        keymode={Astal.Keymode.EXCLUSIVE}
        visible={false}
        application={App}>
        <box vertical>
            {clickOutsideToClose}
            <box className="cheatsheet-bg spacing-v-15" vertical>
                <CheatsheetHeader />
                {keys.getEnabled().map(kb => <box>
                    <box className='spacing-h-10'>
                        <box>
                            {[...getBind(kb).mods, getBind(kb).key].map(k => <label label={k} className='cheatsheet-key txt-small'/>)}
                        </box>
                        <label label={kb.description} className='txt chearsheet-action txt-small' />
                    </box>
                </box>)}
            </box>
        </box>
    </window>
}
