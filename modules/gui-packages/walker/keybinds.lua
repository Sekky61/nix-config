Name = "keybinds"
NamePretty = "Keybinds"
Icon = "applications-other"
Cache = true
HideFromProviderlist = false
Description = "loaded from ~/.config/keybinds.json"
Actions = {
    launch = "sh -lc %VALUE%",
}
SearchName = true

-- verify with `lua -e "dofile('modules/gui-packages/walker/keybinds.lua'); for _,e in ipairs(GetEntries()) do print((e.Text or '') .. ' | ' .. (e.Subtext or '') .. ' | ' .. (e.Value or '')) end"`

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

            local launch_cmd = ""
            if params ~= "" then
                if dispatcher == "" or dispatcher == "exec" then
                    launch_cmd = params
                else
                    launch_cmd = "hyprctl dispatch " .. dispatcher .. " " .. params
                end
            end

            local launch_value = ""
            if launch_cmd ~= "" then
                launch_value = shell_quote(launch_cmd)
            end

            table.insert(entries, {
                Text = title,
                Subtext = subtext,
                Value = launch_value,
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
