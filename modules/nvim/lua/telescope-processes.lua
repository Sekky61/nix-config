-- telescope-processes.lua
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

-- Function to get process information
local function get_processes()
    local handle = io.popen([[ps -eo pid,ppid,user,%cpu,%mem,stat,start,command --sort=-%cpu]])
    if handle == nil then
        return {}
    end
    
    local result = handle:read("*a")
    handle:close()
    
    local processes = {}
    for line in result:gmatch("[^\n]+") do
        table.insert(processes, line)
    end
    
    -- Remove the header line
    table.remove(processes, 1)
    return processes
end

-- Format process entry for display
local function format_entry(entry)
    local fields = {}
    for field in entry:gmatch("%S+") do
        table.insert(fields, field)
    end
    
    -- Extract PID and command
    local pid = fields[1]
    local command = table.concat({unpack(fields, 8)}, " ")
    
    return {
        value = pid,
        display = string.format("%s\t%s\t%s\t%s%%\t%s%%\t%s",
            fields[1],    -- PID
            fields[3],    -- USER
            command,      -- COMMAND
            fields[4],    -- CPU%
            fields[5],    -- MEM%
            fields[7]     -- START
        ),
        ordinal = entry,
    }
end

function M.list_processes(opts)
    opts = opts or {}
    
    pickers.new(opts, {
        prompt_title = "Processes",
        finder = finders.new_table {
            results = get_processes(),
            entry_maker = format_entry,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            -- Add custom actions here
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                
                -- Return the PID of the selected process
                return selection.value
            end)
            
            -- Add kill process mapping
            map('i', '<C-k>', function()
                local selection = action_state.get_selected_entry()
                local pid = selection.value
                local kill_cmd = string.format('kill %s', pid)
                os.execute(kill_cmd)
                actions.close(prompt_bufnr)
            end)
            
            return true
        end,
    }):find()
end

return M
