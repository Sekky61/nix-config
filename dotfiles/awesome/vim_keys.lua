
local my_vim_keys = {

    ["VIM: zlepšováky"] = {{
        modifiers = {},
        keys = {
            ['_d']='delete without yank',
            ['>']='indent'
        }
    }, 
    -- {
    --     modifiers = {"Ctrl"},
    --     keys = {
    --         u="half page up",
    --     }
    -- }
    },
    ["VIM: selects"] = {{
        modifiers = {},
        keys = {
            ['(v/c/d)(i/a)X']="work Inside/Around X, where X is:",
            ['w']="word",
            ['"']="quotes",
            ['(']="parentheses",
            ['{']="braces",

            ['[']="brackets",
            ['t']="tag",
            ['s']="sentence (continous lines)",
            ['p']="paragraph",
            ['b']="block",
            -- ['<']="tags", -- causes problems
        }
    }},
    ["VIM: search"] = {{
        modifiers = {},
        keys = {
            ['*']="search the word under cursor",
            [':s']="search on the line",
            [':%s']="search in the file",
            [':%s/pattern/replace/flags']="flags: c=confirm, i=case_insensitive, g=replace_all", 
            ['N']="previous search",
        }
    }},
    ["NVIM"] = {{
        modifiers = {},
        keys = {
            ['space+space']="See open buffers",
            ['[g']="Next error",
            ['<leader>ca']="Code Action"
        }
    }}
}

return my_vim_keys
