// https://github.com/ollama/ollama/blob/main/docs/api.md

import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Soup from 'gi://Soup?version=3.0';
import { fileExists } from './messages.js';

// Custom prompt
const initMessages =
    [
        { role: "system", content: "You are an assistant on a sidebar of a Linux desktop. You help with programming and linux commands, because you are an expert on it. Keep the responses short and correct. Use markdown and examples.", },
        { role: "user", content: "how to symlink a file", },
        { role: "assistant", content: "```bash\nln -s <original_file> <link_name>\n```\n* `-s` - \"symbolic\", used to create a symbolic link. Without it, `ln` would create a hard link instead." },
    ];

function expandTilde(path) {
    if (path.startsWith('~')) {
        return GLib.get_home_dir() + path.slice(1);
    } else {
        return path;
    }
}

// We're using many models to not be restricted to 3 messages per minute.
// The whole chat will be sent every request anyway.
Utils.exec(`mkdir -p ${GLib.get_user_cache_dir()}/ags/user/ai`);
const KEY_FILE_LOCATION = `${GLib.get_user_cache_dir()}/ags/user/ai/openai_key.txt`;
const APIDOM_FILE_LOCATION = `${GLib.get_user_cache_dir()}/ags/user/openai_api_dom.txt`;
function replaceapidom(URL) {
    //Utils.writeFile(URL, "/tmp/openai-url-old.log"); // For debugging
    if (fileExists(expandTilde(APIDOM_FILE_LOCATION))) {
        var contents = Utils.readFile(expandTilde(APIDOM_FILE_LOCATION)).trim();
        var URL = URL.toString().replace("api.openai.com", contents);
    }
    //Utils.writeFile(URL, "/tmp/openai-url.log"); // For debugging
    return URL;
}

function parseOllamaList(text) {
    const lines = text.trim().split('\n').slice(1); // Ignore the header line
    return lines.map(line => {
        const parts = line.split(/\s{2,}|\t/); // Split by two or more spaces or tabs
        return {
            name: parts[0].trim(),
            id: parts[1].trim(),
            size: parts[2].trim(),
            modified: parts[3].trim()
        };
    });
}

class OllamaMessage extends Service {
    static {
        Service.register(this,
            {
                'delta': ['string'],
            },
            {
                'content': ['string'],
                'thinking': ['boolean'],
                'done': ['boolean'],
            });
    }

    _role = '';
    _content = '';
    _thinking = false;
    _done = false;

    /**
     * Can run after sending the message
     */
    constructor(role, content, thinking = false, done = false) {
        super();
        this._role = role;
        this._content = content;
        this._thinking = thinking;
        this._done = done;
    }

    get done() { return this._done }
    set done(isDone) { 
        this._done = isDone;
        this.thinking = false;
        this.notify('done')
    }

    get role() { return this._role }
    set role(role) { this._role = role; this.emit('changed') }

    get content() { return this._content }
    set content(content) {
        this._content = content;
        this.notify('content')
        this.emit('changed')
    }

    get label() { return this._parserState.parsed + this._parserState.stack.join('') }

    get thinking() { return this._thinking }
    set thinking(thinking) {
        this._thinking = thinking;
        this.notify('thinking')
        this.emit('changed')
    }

    addDelta(delta) {
        if (this.thinking) {
            this.thinking = false;
            this.content = delta;
        }
        else {
            this.content += delta;
        }
        this.emit('delta', delta);
    }
}

class OllamaService extends Service {
    static {
        Service.register(this, {
            'initialized': [],
            'clear': [],
            'newMsg': ['int'],
            'hasKey': ['boolean'],
            'modelsLoaded': []
        });
    }

    // Use initial messages
    _assistantPrompt = true;
    _messages = [];
    // _cycleModels = true;
    _requestCount = 0;
    _temperature = 0.9;
    _modelIndex = 0;
    // _key = '';
    _decoder = new TextDecoder('utf-8', { fatal: false });
    _availableModels = [];

    url = GLib.Uri.parse(replaceapidom('http://localhost:11434/api/chat'), GLib.UriFlags.NONE);

    constructor() {
        super();

        // if (fileExists(expandTilde(KEY_FILE_LOCATION))) this._key = Utils.readFile(expandTilde(KEY_FILE_LOCATION)).trim();
        // else this.emit('hasKey', false);

        if (this._assistantPrompt) this._messages = [...initMessages];
        else this._messages = [];

        this.loadAvailableModels();
        this.emit('initialized');
    }

    async loadAvailableModels() {
        try {
            const text = await Utils.execAsync('ollama list');
            const models =  parseOllamaList(text);
            this.availableModels = models;
        } catch(e) {
            console.error(e);
        }
    }

    get availableModels() { return this._availableModels }
    set availableModels(models) { 
        this._availableModels = models;
        this.notify('modelsLoaded');
        this.emit('changed');
    }

    get activeModel() { return this.availableModels[this._modelIndex]; }

    get modelIndex() { return this._modelIndex; }
    set modelIndex(value) { this._modelIndex = value; }

    get modelName() { return this._availableModels[this._modelIndex].name; }

    // get keyPath() { return KEY_FILE_LOCATION }
    // get key() { return this._key }
    // set key(keyValue) {
    //     this._key = keyValue;
    //     Utils.writeFile(this._key, expandTilde(KEY_FILE_LOCATION))
    //         .then(this.emit('hasKey', true))
    //         .catch(err => print(err));
    // }

    // get cycleModels() { return this._cycleModels }
    // set cycleModels(value) {
    //     this._cycleModels = value;
    //     if (!value) this._modelIndex = 0;
    //     else {
    //         this._modelIndex = (this._requestCount - (this._requestCount % ONE_CYCLE_COUNT)) % CHAT_MODELS.length;
    //     }
    // }

    get temperature() { return this._temperature }
    set temperature(value) { this._temperature = value; }

    get messages() { return this._messages }
    get lastMessage() { return this._messages[this._messages.length - 1] }

    clear() {
        if (this._assistantPrompt)
            this._messages = [...initMessages];
        else
            this._messages = [];
        this.emit('clear');
    }

    get assistantPrompt() { return this._assistantPrompt; }
    set assistantPrompt(value) {
        this._assistantPrompt = value;
        if (value) this._messages = [...initMessages];
        else this._messages = [];
    }

    /**
     * Get a piece of response, add it to message object.
     * @param {Gio.DataInputStream} stream
     * @param {OllamaMessage} aiResponse
     */
    readResponse(stream, aiResponse) {
        stream.read_line_async(
            0, null,
            (stream, res) => {
                if (!stream) return;
                const [bytes] = stream.read_line_finish(res);
                if(!bytes) {
                    return;
                }
                const line = this._decoder.decode(bytes);
                if (line !== null) {
                    try {
                        const result = JSON.parse(line);
                        if (result.done) {
                            aiResponse.done = true;
                            return;
                        }
                        aiResponse.addDelta(result.message.content);
                    }
                    catch {
                        aiResponse.addDelta(line + '\n');
                    }
                }
                this.readResponse(stream, aiResponse);
            });
    }

    addMessage(role, message) {
        this._messages.push(new OllamaMessage(role, message));
        this.emit('newMsg', this._messages.length - 1);
    }

    send(msg) {
        this._messages.push(new OllamaMessage('user', msg));
        this.emit('newMsg', this._messages.length - 1);

        const body = {
            model: this.modelName,
            messages: this._messages.map(msg => { let m = { role: msg.role, content: msg.content }; return m; }),
            temperature: this._temperature,
            stream: true,
        };

        // First copy and post chat, then add the thinking message
        const aiResponse = new OllamaMessage('assistant', 'thinking...', true, false)
        this._messages.push(aiResponse);
        this.emit('newMsg', this._messages.length - 1);

        const session = new Soup.Session();
        const message = new Soup.Message({
            method: 'POST',
            uri: this.url,
        });
        // message.request_headers.append('Authorization', `Bearer ${this._key}`);
        message.set_request_body_from_bytes('application/json', new GLib.Bytes(JSON.stringify(body)));

        session.send_async(message, GLib.DEFAULT_PRIORITY, null, (_, result) => {
            const stream = session.send_finish(result);
            this.readResponse(new Gio.DataInputStream({
                close_base_stream: true,
                base_stream: stream
            }), aiResponse);
        });

        // if (this._cycleModels) {
        //     this._requestCount++;
        //     if (this._cycleModels)
        //         this._modelIndex = (this._requestCount - (this._requestCount % ONE_CYCLE_COUNT)) % CHAT_MODELS.length;
        // }
    }
}

export default new OllamaService();

