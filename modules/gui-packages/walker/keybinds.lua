Name = "keybinds"
NamePretty = "Keybinds"
Icon = "applications-other"
Cache = true
HideFromProviderlist = false
Description = "loaded from ~/.config/keybinds.json"
Action = "notify-send Missing"
SearchName = true

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

function GetEntries()
    local entries = {}
    local home = os.getenv("HOME") or ""
    local keybinds_file = home .. "/.config/keybinds.json"

    local jq_filter = [[
    .[]
    | select((.visible // true) and ((.bind | type) == "object") and (.bind.enable // false) and (.bind.visible // true))
    | . as $entry
    | (if (.command | type) == "array" then .command[] else .command end)
    | select((type == "object") and (.enable // false) and (.visible // true))
    | [($entry.description // ""), (($entry.bind.mods // []) | join("+")), ($entry.bind.key // ""), (.dispatcher // ""), (.params // "")]
    | @tsv
  ]]

    local jq_cmd = "jq -r '" .. jq_filter .. "' " .. shell_quote(keybinds_file) .. " 2>/dev/null"

    local handle = io.popen(jq_cmd)
    if not handle then
        return {
            {
                Text = "Could not read keybinds.json",
                Subtext = keybinds_file,
                Value = "",
            },
        }
    end

    for line in handle:lines() do
        local description, mods, key, dispatcher, params =
            line:match("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)")
        if description and key then
            local shortcut = key
            if mods ~= "" then
                shortcut = mods .. "+" .. key
            end

            local title = description ~= "" and description or shortcut
            local subtext = shortcut
            if dispatcher ~= "" then
                subtext = subtext .. " -> " .. dispatcher
            end

            table.insert(entries, {
                Text = title,
                Subtext = subtext,
                Value = params,
            })
        end
    end

    handle:close()

    if #entries == 0 then
        return {
            {
                Text = "No visible keybinds found",
                Subtext = keybinds_file,
                Value = "",
            },
        }
    end

    return entries
end
