const { Gtk, GObject } = imports.gi;
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

const { Box, Button, Entry, EventBox, Icon, Label, Revealer, Scrollable, Stack } = Widget;
const { execAsync, exec } = Utils;
import Ollama from '../../../services/ollama.js';
import { MaterialIcon } from "../../../lib/materialicon.js";
import { setupCursorHover, setupCursorHoverInfo } from "../../../lib/cursorhover.js";
import { SystemMessage, ChatMessage } from "./ai_chatmessage.js";
import { ConfigToggle, ConfigSegmentedSelection, ConfigGap } from '../../../lib/configwidgets.js';
import { markdownTest } from '../../../lib/md2pango.js';
import { MarginRevealer } from '../../../lib/advancedwidgets.js';

export const localTabIcon = Icon({
    hpack: 'center',
    className: 'sidebar-chat-apiswitcher-icon',
    icon: `ollama-symbolic`,
})

const LocalInfo = () => {
    const localLogo = Icon({
        hpack: 'center',
        className: 'sidebar-chat-welcome-logo',
        icon: `ollama-symbolic`,
    });
    return Box({
        vertical: true,
        className: 'spacing-v-15',
        children: [
            localLogo,
            Label({
                className: 'txt txt-title-small sidebar-chat-welcome-txt',
                wrap: true,
                justify: Gtk.Justification.CENTER,
                label: 'Ollama models',
            }),
            Box({
                className: 'spacing-h-5',
                hpack: 'center',
                children: [
                    Label({
                        className: 'txt-smallie txt-subtext',
                        wrap: true,
                        justify: Gtk.Justification.CENTER,
                        label: 'Local models ftw!',
                    }),
                ]
            }),
        ]
    });
}

const ModelPicker = () => {
    // Source: https://stackoverflow.com/questions/21568268/how-to-use-the-gtk-combobox-in-gjs
    let model = new Gtk.ListStore();
    model.set_column_types([GObject.TYPE_STRING, GObject.TYPE_STRING]);

    let cbox = new Gtk.ComboBox({
        model: model,
    });
    let renderer = new Gtk.CellRendererText();
    cbox.pack_start(renderer, true);
    cbox.add_attribute(renderer, 'text', 1);

    // cbox.set_active(0); // set value

    cbox.connect('changed', function(entry) {
        let [success, iter] = cbox.get_active_iter();
        if (!success)
        return;
        let index = model.get_value(iter, 0); // get value
        console.log('picked', index);
        Ollama.modelIndex = index;
    });

    const button =  Box({
        className: 'model-dropdown',
        child: Widget.CenterBox({
            startWidget: cbox,
            endWidget: Box({
                hpack: 'center',
                className: 'sidebar-chat-apiswitcher-icon',
                homogeneous: true,
                children: [
                    MaterialIcon('keyboard_arrow_down', 'norm'),
                ]
            })
        }),
        hpack: 'center',
        setup: (self) => self
            .hook(Ollama, (box, legit) => {
                if(!legit) return; // gets run at startup
                console.log('event loaded', box, legit);
                const models = Ollama.availableModels;
                models.forEach((modelObj, i) => {
                    console.log('adding', modelObj, i);
                    model.set(model.append(), [0, 1], [i, modelObj.name]);
                });
                cbox.set_active(0); // set value
            }, 'modelsLoaded')
    });
    return button;
};


export const LocalSettings = () => MarginRevealer({
    transition: 'slide_down',
    revealChild: true,
    extraSetup: (self) => self
        .hook(Ollama, (self) => Utils.timeout(200, () => {
            self.attribute.hide();
        }), 'newMsg')
        .hook(Ollama, (self) => Utils.timeout(200, () => {
            self.attribute.show();
        }), 'clear')
    ,
    child: Box({
        vertical: true,
        className: 'sidebar-chat-settings',
        children: [
            ConfigSegmentedSelection({
                hpack: 'center',
                icon: 'casino',
                name: 'Randomness',
                desc: 'Temperature value.\n  Precise = 0\n  Balanced = 0.5\n  Creative = 1',
                options: [
                    { value: 0.00, name: 'Precise', },
                    { value: 0.50, name: 'Balanced', },
                    { value: 1.00, name: 'Creative', },
                ],
                initIndex: 2,
                onChange: (value, name) => {
                    Ollama.temperature = value;
                },
            }),
            ConfigGap({ vertical: true, size: 10 }), // Note: size can only be 5, 10, or 15 
            ModelPicker(),
            // Box({
            //     vertical: true,
            //     hpack: 'fill',
            //     className: 'sidebar-chat-settings-toggles',
            //     children: [
            //         ConfigToggle({
            //             icon: 'model_training',
            //             name: 'Enhancements',
            //             desc: 'Tells Gemini:\n- It\'s a Linux sidebar assistant\n- Be brief and use bullet points',
            //             initValue: Ollama.assistantPrompt,
            //             onChange: (self, newValue) => {
            //                 Ollama.assistantPrompt = newValue;
            //             },
            //         }),
            //     ]
            // })
        ]
    })
});

const localWelcome = Box({
    vexpand: true,
    homogeneous: true,
    child: Box({
        className: 'spacing-v-15',
        vpack: 'center',
        vertical: true,
        children: [
            LocalInfo(),
            LocalSettings(),
        ]
    })
});

export const chatContent = Box({
    className: 'spacing-v-15',
    vertical: true,
    setup: (self) => self
        .hook(Ollama, (box, id) => {
            const message = Ollama.messages[id];
            if (!message) return;
            box.add(ChatMessage(message, Ollama.modelName))
        }, 'newMsg')
    ,
});

const clearChat = () => {
    Ollama.clear();
    const children = chatContent.get_children();
    for (let i = 0; i < children.length; i++) {
        const child = children[i];
        child.destroy();
    }
}

export const localView = Scrollable({
    className: 'sidebar-chat-viewport',
    vexpand: true,
    child: Box({
        vertical: true,
        children: [
            localWelcome,
            chatContent,
        ]
    }),
    setup: (scrolledWindow) => {
        // Show scrollbar
        scrolledWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        const vScrollbar = scrolledWindow.get_vscrollbar();
        vScrollbar.get_style_context().add_class('sidebar-scrollbar');
        // Avoid click-to-scroll-widget-to-view behavior
        Utils.timeout(1, () => {
            const viewport = scrolledWindow.child;
            viewport.set_focus_vadjustment(new Gtk.Adjustment(undefined));
        })
        // Always scroll to bottom with new content
        const adjustment = scrolledWindow.get_vadjustment();
        adjustment.connect("changed", () => {
            adjustment.set_value(adjustment.get_upper() - adjustment.get_page_size());
        })
    }
});

const CommandButton = (command) => Button({
    className: 'sidebar-chat-chip sidebar-chat-chip-action txt txt-small',
    onClicked: () => sendMessage(command),
    setup: setupCursorHover,
    label: command,
});

export const localCommands = Box({
    className: 'spacing-h-5',
    children: [
        Box({ hexpand: true }),
        CommandButton('/key'),
        CommandButton('/model'),
        CommandButton('/clear'),
    ]
});

export const sendMessage = (text) => {
    // Check if text or API key is empty
    if (text.length == 0) return;
    // Commands
    if (!text.startsWith('/')) {
        Ollama.send(text);
        return;
    }

    if (text.startsWith('/clear')) clearChat();
    else if (text.startsWith('/model')) chatContent.add(SystemMessage(`Currently using \`${Ollama.modelName}\``, '/model', localView))
    else if (text.startsWith('/prompt')) {
        const firstSpaceIndex = text.indexOf(' ');
        const prompt = text.slice(firstSpaceIndex + 1);
        if (firstSpaceIndex == -1 || prompt.length < 1) {
            chatContent.add(SystemMessage(`Usage: \`/prompt MESSAGE\``, '/prompt', localView))
        }
        else {
            Ollama.addMessage('user', prompt)
        }
    }
    else if (text.startsWith('/test'))
        chatContent.add(SystemMessage(markdownTest, `Markdown test`, localView));
    else
        chatContent.add(SystemMessage(`Invalid command.`, 'Error', localView))
}

