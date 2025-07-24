-- Neovim config. Michal Majer

-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local dev_mode = vim.env.DEV_MODE == "1"

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

js_formatters = { "prettierd", "prettier", "biome", stop_after_first = true }
-- js_formatters = { "biome", stop_after_first = true }

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "htmlangular" },
    callback = function()
        vim.opt_local.iskeyword:append("$")
    end,
})

-- Override lsp configuration (base is taken from nvim-lspconfig
-- Link: https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
local servers = {
    clangd = {},
    pyright = {},
    rust_analyzer = {},
    jsonls = {},
    nil_ls = {}, -- nix
    gopls = {},
    omnisharp = {},

    html = { filetypes = { "html", "twig", "hbs" } },
    -- htmx = {},
    -- custom_elements_ls = {},
    cssls = { filetypes = { "scss", "less", "stylus", "css" } },
    -- This rascal kills ram
    -- tailwindcss = {},
    angularls = {},
    yamlls = {},
    vtsls = {}, -- typescript server
    biome = {
        cmd = { "./node_modules/.bin/biome", "lsp-proxy" },
    },
    astro = {},
    eslint = {},
    emmet_ls = {
        filetypes = {
            "css",
            "eruby",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "sass",
            "scss",
            "svelte",
            "pug",
            "typescriptreact",
            "vue",
        },
    },
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

require("lazy").setup({
    -- Git related plugins
    "tpope/vim-rhubarb",
    "https://tpope.io/vim/fugitive.git",

    -- Detect tabstop and shiftwidth automatically
    "tpope/vim-sleuth",

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
    },
    {
        -- Useful status updates (right bottom corner)
        "j-hui/fidget.nvim",
        opts = {},
    },
    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",

            -- Adds LSP completion capabilities
            "hrsh7th/cmp-nvim-lsp",

            -- Adds a number of user-friendly snippets
            "rafamadriz/friendly-snippets",

            -- Adds words from buffer to completion list
            "hrsh7th/cmp-buffer",

            -- cmdline
            "hrsh7th/cmp-cmdline",

            -- Spelling
            "f3fora/cmp-spell",
        },
    },
    "lukas-reineke/cmp-rg", -- ripgrep in nvim-cmp
    "jcha0713/cmp-tw2css", -- tailwind classes to css
    "hrsh7th/cmp-nvim-lsp-document-symbol",

    -- Useful plugin to show you pending keybinds.
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        "lewis6991/gitsigns.nvim",
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            current_line_blame = true,
            current_line_blame_formatter = "<author>, <author_time>, <abbrev_sha> -> <summary>",
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, {
                        buffer = bufnr,
                        desc = "Git: " .. desc,
                    })
                end

                map("n", "[h", function()
                    gs.nav_hunk("prev", { target = "all" })
                end, "Go to Previous [H]unk")
                map("n", "]h", function()
                    gs.nav_hunk("next", { target = "all" })
                end, "Go to Next [H]unk")
                map("n", "<leader>tb", gs.toggle_current_line_blame, "[T]oggle line [B]lame")
                map({ "n", "v" }, "<leader>hs", gs.stage_hunk, "[S]tage [H]unk")
                map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "[R]eset [H]unk")
                map("n", "<leader>hS", gs.stage_buffer, "[S]tage buffer")
                map("n", "<leader>hu", gs.undo_stage_hunk, "[H]unk [U]ndo stage")
                map("n", "<leader>hR", gs.reset_buffer, "[R]eset buffer")
                map("n", "<leader>hp", gs.preview_hunk, "[H]unk [P]review")
                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end, "[B]lame line")
                map("n", "<leader>hd", gs.diffthis, "[H]unk [D]iff")
                map("n", "<leader>hD", function()
                    gs.diffthis("~")
                end, "buffer [D]iff")
            end,
        },
    },

    -- Theme
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

    {
        -- Set lualine as statusline
        "nvim-lualine/lualine.nvim",
        -- See `:help lualine.txt`
        opts = {
            options = {
                theme = "catppuccin",
                component_separators = "󰇙",
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_c = {
                    function()
                        local full_path = vim.fn.expand("%:p")

                        -- split the path into parts
                        local parts = {}
                        for part in full_path:gmatch("[^/]+") do
                            table.insert(parts, part)
                        end

                        -- find 'modules' and get the next directory
                        for i, part in ipairs(parts) do
                            if part == "modules" and i < #parts then
                                return " " .. parts[i + 1] -- return the directory after 'modules'
                            end
                        end

                        return "" -- return empty if 'modules' not found or no subdirectory after it
                    end,
                    function()
                        local full_path = vim.fn.expand("%:p")
                        local cwd = vim.fn.getcwd()

                        -- check if the file path starts with the cwd
                        if full_path:find(cwd, 1, true) then
                            full_path = full_path:sub(#cwd + 2) -- remove cwd and leading slash
                        end

                        -- split the path into parts
                        local parts = {}
                        for part in full_path:gmatch("[^/]+") do
                            table.insert(parts, part)
                        end

                        -- find the starting point (first 'src' and exclude it)
                        local start_index = 1
                        for i, part in ipairs(parts) do
                            if part == "src" then
                                start_index = i + 1
                                break
                            end
                        end

                        -- reconstruct the trimmed path from after 'src' to the filename
                        return table.concat(vim.list_slice(parts, start_index, #parts), "")
                    end,
                },
            },
        },
    },

    {
        -- Add indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = "ibl",
        opts = {
            indent = {
                highlight = {
                    "CursorColumn",
                    "Whitespace",
                },
                char = "",
            },
            whitespace = {
                highlight = {
                    "CursorColumn",
                    "Whitespace",
                },
                remove_blankline_trail = false,
            },
            scope = { enabled = false },
        },
    },

    -- Fuzzy Finder (files, lsp, etc)
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "debugloop/telescope-undo.nvim",
            "fdschmidt93/telescope-egrepify.nvim",
            {
                -- Fuzzy Finder Algorithm which requires local dependencies to be built.
                -- Only load if `make` is available. Make sure you have the system
                -- requirements installed.
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
        config = function()
            local ts = require("telescope")
            local ts_undo = require("telescope-undo.actions")
            local processes_picker = require("telescope-processes")

            local h_pct = 0.95
            local w_pct = 0.98
            local w_limit = 75

            local style_base = {
                borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                preview = { hide_on_startup = false },
                winblend = 8,
            }
            local behavior_base = {
                sorting_strategy = "ascending",
                file_ignore_patterns = { ".git/", ".cache", "%.o", "%.a", "%.out", "%.class" },
                mappings = {
                    -- <C-/> to see all binds
                    -- <C-t> to open in new tab
                    -- <C-x> to open in split
                    -- <C-v> to open in vsplit
                    n = {
                        ["o"] = require("telescope.actions.layout").toggle_preview,
                        ["<C-c>"] = require("telescope.actions").close,
                        ["<c-t>"] = require("trouble.sources.telescope").open,
                    },
                    i = {
                        ["<C-h>"] = require("telescope.actions.layout").toggle_preview,
                        ["<c-t>"] = require("trouble.sources.telescope").open,
                        ["<C-Down>"] = require("telescope.actions").cycle_history_next,
                        ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
                    },
                },
            }

            local standard_setup = {
                layout_config = {
                    vertical = {
                        mirror = true,
                        prompt_position = "top",
                        width = function(_, cols, _)
                            return math.min(math.floor(w_pct * cols), w_limit)
                        end,
                        height = function(_, _, rows)
                            return math.floor(rows * h_pct)
                        end,
                        preview_cutoff = 10,
                    },
                },
            }
            local fullscreen_setup = {
                layout_strategy = "flex",
                path_display = {
                    shorten = { len = 2, exclude = { 1, -2, -1 } },
                },
                layout_config = {
                    flex = { flip_columns = 100 },
                    horizontal = {
                        mirror = false,
                        prompt_position = "top",
                        width = function(_, cols, _)
                            return math.floor(cols * w_pct)
                        end,
                        height = function(_, _, rows)
                            return math.floor(rows * h_pct)
                        end,
                        preview_cutoff = 10,
                        preview_width = 0.5,
                    },
                    vertical = {
                        mirror = true,
                        prompt_position = "top",
                        width = function(_, cols, _)
                            return math.floor(cols * w_pct)
                        end,
                        height = function(_, _, rows)
                            return math.floor(rows * h_pct)
                        end,
                        preview_cutoff = 10,
                    },
                },
            }
            local vertical_setup = {
                layout_strategy = "vertical",
                path_display = function(opts, path)
                    local utils = require("telescope.utils")
                    if path:len() > (vim.api.nvim_win_get_width(0) - 10) then
                        return utils.transform_path({
                            path_display = {
                                shorten = { len = 3, exclude = { 1, -3, -2, -1 } },
                            },
                        }, path)
                    end
                    return utils.transform_path({
                        path_display = {
                            truncate = 2,
                        },
                    }, path)
                end,
                layout_config = {
                    mirror = true,
                    prompt_position = "top",
                    width = function(_, cols, _)
                        return math.floor(cols * w_pct)
                    end,
                    height = function(_, _, rows)
                        return math.floor(rows * h_pct)
                    end,
                    preview_cutoff = 10,
                },
            }
            local egrep_actions = require("telescope._extensions.egrepify.actions")
            ts.setup({
                defaults = vim.tbl_extend("error", style_base, vertical_setup, behavior_base),
                pickers = {
                    find_files = {
                        find_command = {
                            "fd",
                            "--type",
                            "f",
                            "-H",
                            "--strip-cwd-prefix",
                        },
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({
                            -- even more opts
                        }),
                    },
                    undo = vim.tbl_extend("error", fullscreen_setup, {
                        vim_context_lines = 4,
                        preview_title = "Diff",
                        mappings = {
                            i = {
                                ["<cr>"] = ts_undo.restore,
                                ["<C-cr>"] = ts_undo.restore,
                                ["<C-y>d"] = ts_undo.yank_deletions,
                                ["<C-y>a"] = ts_undo.yank_additions,
                            },
                            n = {
                                ["<cr>"] = ts_undo.restore,
                                ["ya"] = ts_undo.yank_additions,
                                ["yd"] = ts_undo.yank_deletions,
                            },
                        },
                    }),
                    egrepify = {
                        -- intersect tokens in prompt ala "str1.*str2" that ONLY matches
                        -- if str1 and str2 are consecutively in line with anything in between (wildcard)
                        permutations = false, -- opt-in to imply AND & match all permutations of prompt tokens
                        results_ts_hl = true, -- set to false if you experience latency issues!
                        -- suffix = long line, see screenshot
                        -- EXAMPLE ON HOW TO ADD PREFIX!
                        prefixes = {
                            -- ADDED ! to invert matches
                            -- example prompt: ! sorter
                            -- matches all lines that do not comprise sorter
                            -- rg --invert-match -- sorter
                            ["!"] = {
                                flag = "invert-match",
                            },
                            -- HOW TO OPT OUT OF PREFIX
                            -- ^ is not a default prefix and safe example
                            ["^"] = false,
                        },
                        -- default mappings
                        mappings = {
                            i = {
                                -- toggle prefixes, prefixes is default
                                ["<C-z>"] = egrep_actions.toggle_prefixes,
                                -- toggle AND, AND is default, AND matches tokens and any chars in between
                                ["<C-a>"] = egrep_actions.toggle_and,
                                -- toggle permutations, permutations of tokens is opt-in
                                ["<C-r>"] = egrep_actions.toggle_permutations,
                            },
                        },
                    },
                },
            })
            ts.load_extension("fzf")
            ts.load_extension("undo")
            ts.load_extension("ui-select")
            ts.load_extension("egrepify")

            -- See `:help telescope.builtin`
            local tsb = require("telescope.builtin")
            vim.keymap.set(
                "n",
                "<leader><space>",
                tsb.oldfiles,
                { desc = "[ ] Find recently opened files" }
            )
            vim.keymap.set("n", "<leader>?", function()
                tsb.buffers({ sort_mru = true })
            end, { desc = "[?] Find existing buffers" })
            vim.keymap.set(
                "n",
                "<leader>/",
                tsb.current_buffer_fuzzy_find,
                { desc = "[/] Fuzzily search in current buffer" }
            )

            -- <C-q>    Send all items not filtered to quickfixlist (qflist)
            -- combine with :cdo (apply command to all items in quickfix list)
            vim.keymap.set("n", "<leader>gf", tsb.git_files, { desc = "Search [G]it [F]iles" })
            vim.keymap.set("n", "<leader>sf", tsb.find_files, { desc = "[S]earch [F]iles" })
            vim.keymap.set("n", "<leader>sh", tsb.help_tags, { desc = "[S]earch [H]elp" })
            vim.keymap.set("n", "<leader>sw", tsb.grep_string, { desc = "[S]earch current [W]ord" })
            vim.keymap.set("n", "<leader>sg", tsb.live_grep, { desc = "[S]earch by [G]rep" })
            vim.keymap.set("n", "<leader>sd", tsb.diagnostics, { desc = "[S]earch [D]iagnostics" })
            vim.keymap.set("n", "<leader>ss", tsb.git_status, { desc = "[S]earch [S]tatus" })
            vim.keymap.set("n", "<leader>sr", tsb.resume, { desc = "[S]earch [R]esume" })
            vim.keymap.set("n", "<leader>s=", tsb.spell_suggest, { desc = "[S]earch Spelling [=]" })
            vim.keymap.set("n", "<leader>sk", tsb.keymaps, { desc = "[S]earch [K]eymaps" })
            vim.keymap.set("n", "<leader>sj", tsb.jumplist, { desc = "[S]earch [J]umplist" }) -- <C-O> to go back, <C-I> to go forward
            vim.keymap.set("n", "<leader>sx", tsb.marks, { desc = "[S]earch Mar[x]" }) -- <m(LETTER)> to set, <'(LETTER)> to go there. USE CAPITAL LETTERS FOR GLOBAL MARKS!

            vim.keymap.set("n", "<leader>sm", function()
                tsb.builtin({ include_extensions = true })
            end, { desc = "[S]earch [M]enu" })

            vim.keymap.set("n", "<leader>sc", function()
                require("telescope.builtin").find_files({
                    cwd = vim.fn.expand("%:p:h"),
                })
            end, { desc = "[S]earch from [C]urrent dir" })

            -- see treesitter symbols
            vim.keymap.set(
                "n",
                "<leader>sv",
                tsb.treesitter,
                { desc = "[S]earch [V]ariables (Treesitter Symbols)" }
            )
            vim.keymap.set(
                "n",
                "<leader>sp",
                processes_picker.list_processes,
                { desc = "[S]earch [P]rocesses" }
            )

            -- undo
            vim.keymap.set(
                "n",
                "<leader>su",
                "<cmd>Telescope undo<cr>",
                { desc = "[S]earch [U]udo" }
            )

            vim.keymap.set(
                "n",
                "<leader>se",
                "<cmd>Telescope egrepify<cr>",
                { desc = "[S]earch [E]grepify" }
            )
        end,
    },

    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        build = ":TSUpdate",
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false,
                },
            })
        end,
    },
    {
        -- https://github.com/numToStr/Comment.nvim
        -- gc{motion}, gcc, gbc
        "numToStr/Comment.nvim",
        opts = {
            -- add any options here
        },
    },
    {
        -- Session management. <leader>sm and "session" to get menu of all sessions
        "rmagatti/auto-session",
        lazy = false,

        ---enables autocomplete for opts
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            suppressed_dirs = { "~/", "~/Documents", "~/Downloads", "/" },
        },
    },
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },

    {
        -- treesitter context (function header visible on top)
        -- TODO bugs in Octo PR review?
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 20, -- Maximum number of lines to show for a single context
            trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
            -- Separator between context and content. Should be a single character string, like '-'.
            -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
            separator = nil,
            zindex = 20, -- The Z-index of the context window
            on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        },
    },
    -- history tree
    "mbbill/undotree",
    -- completions for command line
    "hrsh7th/cmp-cmdline",
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    {
        -- LLM
        "yetone/avante.nvim",
        build = "make",
        event = "VeryLazy",
        version = false, -- set this if you want to always pull the latest change
        opts = {
            provider = "openrouter",
            cursor_applying_provider = "groq",
            behaviour = {
                enable_cursor_planning_mode = true, -- enable cursor planning mode!
            },
            providers = {
                groq = {
                    __inherited_from = "openai",
                    api_key_name = "GROQ_API_KEY",
                    endpoint = "https://api.groq.com/openai/v1/",
                    model = "llama-3.3-70b-versatile",
                    extra_request_body = {
                        max_completion_tokens = 32768,
                    },
                },
                ollama = {
                    __inherited_from = "openai",
                    api_key_name = "",
                    endpoint = "http://127.0.0.1:11434/v1",
                    model = "deepseek-r1:14b",
                },
                openrouter = {
                    __inherited_from = "openai",
                    endpoint = "https://openrouter.ai/api/v1",
                    api_key_name = "OPENROUTER_API_KEY",
                    model = "openai/gpt-4.1",
                },
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with 'keys' is recommended in
        -- order to load the plugin when the command is run for the first time
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
    },
    {
        -- Git plugin
        "NeogitOrg/neogit",
        dependencies = {
            -- "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration
            -- Only one of these is needed.
            -- "nvim-telescope/telescope.nvim", -- optional
        },
        config = true,
        keys = {
            {
                "<leader>ng",
                function()
                    require("neogit").open({ kind = "vsplit" })
                end,
                desc = "Neogit",
            },
        },
    },
    {
        -- Github plugin
        -- Keys: https://github.com/pwntester/octo.nvim?tab=readme-ov-file#-configuration
        "pwntester/octo.nvim",
        opts = {
            use_local_fs = true, -- right hand side is my actual file with lsp
        },
        keys = {
            {
                -- To respond to review, open another review
                "<leader>oc",
                ":Octo actions<CR>",
                desc = "Open Octo Github menu",
            },
        },
    },
    -- DAP
    {
        -- Source: https://github.com/tjdevries/config.nvim/blob/master/lua/custom/plugins/dap.lua
        "mfussenegger/nvim-dap",
        dependencies = {
            "leoluz/nvim-dap-go",
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "williamboman/mason.nvim",
        },
        config = function()
            local dap = require("dap")
            local ui = require("dapui")

            require("dapui").setup()
            require("dap-go").setup()

            require("nvim-dap-virtual-text").setup({})

            vim.keymap.set(
                "n",
                "<leader>bb",
                dap.toggle_breakpoint,
                { desc = "Toggle [B]reakpoint" }
            )
            vim.keymap.set("n", "<leader>bp", dap.run_to_cursor, { desc = "Run to [P]osition" })

            -- Eval var under cursor
            vim.keymap.set("n", "<space>be", function()
                require("dapui").eval(nil, { enter = true })
            end, { desc = "[E]val under cursor" })

            vim.keymap.set("n", "<leader>bc", dap.continue, { desc = "[C]ontinue" })
            -- A is ALT
            vim.keymap.set("n", "<S-l>", dap.step_into, { desc = "[F2] Step into" })
            vim.keymap.set("n", "<S-j>", dap.step_over, { desc = "[F3] Step over" })
            vim.keymap.set("n", "<S-h>", dap.step_out, { desc = "[F4] Step out" })
            vim.keymap.set("n", "<S-k>", dap.step_back, { desc = "[F5] Step back" })
            vim.keymap.set("n", "<leader>br", dap.restart, { desc = "[R]estart" })
            vim.keymap.set("n", "<leader>bt", dap.terminate, { desc = "[T]erminate" })
            vim.keymap.set("n", "<leader>bl", dap.list_breakpoints, { desc = "[L]ist breakpoints" })
            vim.keymap.set("n", "<leader>bg", dap.repl.open, { desc = "[G]et REPL" })
            vim.keymap.set("n", "<leader>bp", dap.pause, { desc = "[P]ause thread" })
            vim.keymap.set("n", "<leader>bn", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "[N]ew breakpoint with condition" })

            dap.listeners.before.attach.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                ui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                ui.close()
            end

            local js_based_languages =
                { "typescript", "javascript", "typescriptreact", "javascriptreact" }
            for _, language in ipairs(js_based_languages) do
                dap.configurations[language] = {
                    -- ...
                    {
                        name = "Next.js: debug server-side",
                        type = "node2",
                        request = "attach",
                        port = 9231,
                        skipFiles = { "<node_internals>/**", "node_modules/**" },
                        cwd = "${workspaceFolder}",
                    },
                    -- ...
                }
            end

            local make_lldb_config = function(language)
                return {
                    {
                        type = "codelldb",
                        name = "Launch " .. language .. " program by path",
                        request = "launch",
                        program = "${command:pickFile}",
                        cwd = "${workspaceFolder}",
                        stopOnEntry = false,
                        args = {},
                        runInTerminal = false,
                    },

                    {
                        type = "codelldb",
                        name = "Attach to " .. language .. " program",
                        request = "attach",
                        pid = "${command:pickProcess}",
                        port = 7000,
                    },
                }
            end
            local lldb_langs = { "c", "cpp", "rust", "zig", "go" }

            for _, lang in ipairs(lldb_langs) do
                dap.configurations[lang] = make_lldb_config(lang)
            end
        end,
    },

    { "williamboman/mason.nvim", opts = {} },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = vim.tbl_filter(function(server)
                -- by relyling on biome from node_modules, it is not used in project where it is not installed
                return server ~= "biome"
            end, vim.tbl_keys(servers)),
            automatic_enable = vim.tbl_keys(servers),
        },
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
            -- launguages, not adapter names
            -- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
            ensure_installed = { "bash", "codelldb", "python", "cppdbg", "js", "javadbg", "node2" },
            automatic_installation = true,
            handlers = {}, -- The defaults
            adapters = {
                codelldb = {
                    type = "server",
                    host = "127.0.0.1",
                    port = 13000, -- 💀 Use the port printed out or specified with `--port`
                },
            },
        },
    },
    -- auto install things outside of LSPs
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            -- a list of all tools you want to ensure are installed upon start
            -- In practice, put here what lspconfig does not recognise
            -- Can install anything from https://github.com/mason-org/mason-registry/tree/main/packages
            ensure_installed = {
                "stylua",
                "nxls",
                -- by relyling on prettier from node_modules, it is not used in project where it is not installed
                -- "prettierd",
            },
        },
    },

    -- my experiment
    {
        "Sekky61/lsp-sample-extractor.nvim",
        dir = dev_mode and vim.fn.expand("~/Documents/lsp-sample-extractor.nvim") or nil,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            {
                "<leader>lx",
                "<Plug>(lsp_sample_get)",
                desc = "Extract code sample",
                mode = { "n", "x" },
            },
        },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                -- Customize or remove this keymap to your liking
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,

                mode = "",
                desc = "Format buffer",
            },
        },
        ---@module "conform"
        ---@type conform.setupOpts
        opts = {
            format_on_save = function(bufnr)
                -- Disable with a global or buffer-local variable
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 2000 }
            end,
            formatters_by_ft = {
                lua = { "stylua" },
                -- Conform will run multiple formatters sequentially
                python = { "isort", "black" },
                -- You can customize some of the format options for the filetype (:help conform.format)
                rust = { "rustfmt", lsp_format = "fallback" },
                -- Conform will run the first available formatter
                json = { "biome" },
                jsonc = { "biome" },
                javascript = js_formatters,
                typescript = js_formatters,
                typescriptreact = js_formatters,
                javascriptreact = js_formatters,
                nix = { "alejandra" },
                html = { "prettierd", "prettier" },
                htmlangular = { "prettierd", "prettier" },
                -- todo bash formatting
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
        },
    },
    ---@type LazySpec
    {
        "mikavilpas/yazi.nvim",
        event = "VeryLazy",
        dependencies = {
            -- check the installation instructions at
            -- https://github.com/folke/snacks.nvim
            "folke/snacks.nvim",
        },
        keys = {
            {
                "<leader>-",
                mode = { "n", "v" },
                "<cmd>Yazi<cr>",
                desc = "Open yazi at the current file",
            },
            {
                -- Open in the current working directory
                "<leader>cw",
                "<cmd>Yazi cwd<cr>",
                desc = "Open the file manager in nvim's working directory",
            },
            {
                "<c-up>",
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session",
            },
        },
        ---@type YaziConfig
        opts = {
            -- if you want to open yazi instead of netrw, see below for more info
            open_for_directories = false,
            keymaps = {
                show_help = "<f1>",
            },
        },
    },
    {
        "nvzone/typr",
        dependencies = "nvzone/volt",
        opts = {},
        cmd = { "Typr", "TyprStats" },
    },
    -- todo find alternative
    -- {
    --     "chikko80/error-lens.nvim",
    --     event = "BufRead",
    --     dependencies = {
    --         "nvim-telescope/telescope.nvim",
    --     },
    --     opts = {
    --         -- your options go here
    --         auto_adjust = {
    --             enable = true,
    --             fallback_bg_color = "#281478", -- mandatory if enable true (e.g. #281478)
    --             step = 3, -- inc: colors should be brighter/darker
    --             total = 30, -- steps of blender
    --         },
    --     },
    -- },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- set the bottom safe area
vim.opt.scrolloff = 8

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Draw a line at the 80th character
vim.opt.colorcolumn = "80"

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = "unnamedplus,unnamed"

if vim.fn.has("wsl") == 1 then
    -- use the OSC52 clipboard provider (SSH usecase)
    vim.g.clipboard = "osc52"
end

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Window border (todo once https://github.com/nvim-lua/plenary.nvim/pull/649 is merged)
-- https://github.com/nvim-telescope/telescope.nvim/issues/3436
-- vim.o.winborder = "rounded"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect,fuzzy"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- spell checking requires
-- z= or <leader>s= for suggestions
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require("nvim-treesitter.configs").setup({
    modules = {},
    ignore_install = {},
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
        "html",
        "javascript",
        "c",
        "cpp",
        "go",
        "lua",
        "python",
        "rust",
        "tsx",
        "zig",
        "typescript",
        "vimdoc",
        "vim",
        "json",
        "yaml",
        "toml",
        "css",
        "scss",
        "tsx",
        "csv",
        "diff",
        "dockerfile",
        "bash",
        "markdown",
        "nix",
        "angular",
    },
    sync_install = false,

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = true,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<c-space>",
            node_incremental = "<c-space>",
            scope_incremental = "<c-s>",
            node_decremental = "<M-space>",
        },
    },
    textobjects = {
        -- peek definition with treesitter
        lsp_interop = {
            enable = true,
            border = "none",
            floating_preview_opts = {},
            peek_definition_code = {
                ["<leader>df"] = "@function.outer",
                ["<leader>dF"] = "@class.outer",
            },
        },
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["ap"] = { query = "@parameter.outer", desc = "parameter" },
                ["ip"] = { query = "@parameter.inner", desc = "parameter" },
                ["af"] = { query = "@function.outer", desc = "function" },
                ["if"] = { query = "@function.inner", desc = "function" },
                ["ac"] = { query = "@class.outer", desc = "class" },
                ["ic"] = { query = "@class.inner", desc = "class" },
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]f"] = "@function.outer",
                ["]]"] = "@class.outer",
                ["]o"] = "@loop.*",
                ["]c"] = "@conditional.outer",
                ["]b"] = "@block.outer",
                ["]s"] = "@statement.outer",
            },
            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[["] = "@class.outer",
                ["[o"] = "@loop.*",
                ["[c"] = "@conditional.outer",
                ["[b"] = "@block.outer",
                ["[s"] = "@statement.outer",
            },
            goto_previous_end = {
                ["[F"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>A"] = "@parameter.inner",
            },
        },
    },
})

-- Make treesitter motions repeatable with ; and ,
local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- vim way: ; goes to the direction you were moving.
-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

-- error lens, source: https://github.com/Civitasv/runvim/tree/master
local signs = {
    { name = "DiagnosticSignError", text = " " },
    { name = "DiagnosticSignWarn", text = " " },
    { name = "DiagnosticSignHint", text = " " },
    { name = "DiagnosticSignInfo", text = " " },
}
for _, sign in ipairs(signs) do
    -- left side symbols
    -- todo will be deprecated
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
end

vim.diagnostic.config({
    virtual_text = { prefix = "" },
    signs = {
        active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "single",
        source = true,
        header = "",
        prefix = "",
    },
})

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({
        count = -1,
        float = true,
        severity = { min = vim.diagnostic.severity.WARN },
    })
end, { desc = "Jump to previous diagnostic" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({
        count = 1,
        float = true,
        severity = { min = vim.diagnostic.severity.WARN },
    })
end, { desc = "Jump to next diagnostic" })

vim.keymap.set(
    "n",
    "<leader>e",
    vim.diagnostic.open_float,
    { desc = "Open floating diagnostic message" }
)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" }) -- use <leader>xx instead

-- rename LSP priority ----------------------------------------------------------------------
-- Source: https://github.com/fightingdreamer/dotfiles/blob/54bb8b90b1741f58e02e1911cb6de73d48160247/lua/nv/lua/core/opts_lsp.lua#L93

local lsp_have_feature = {
    rename = function(client)
        return client.supports_method("textDocument/rename")
    end,
}

local function get_lsp_client_names(have_feature)
    local client_names = {}
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(attached_clients) do
        if have_feature(client) then
            table.insert(client_names, client.name)
        end
    end
    return client_names
end

local function lsp_buf_rename(client_name)
    vim.lsp.buf.rename(nil, { name = client_name })
end

local function lsp_buf_rename_use_one(fallback)
    local client_names = get_lsp_client_names(lsp_have_feature.rename)
    if #client_names == 1 then
        lsp_buf_rename(client_names[1])
        return
    end
    if fallback then
        fallback()
    end
end

local function lsp_buf_rename_use_select(fallback)
    local client_names = get_lsp_client_names(lsp_have_feature.rename)
    local prompt = "Select lsp client for rename operation"
    local function on_choice(client_name)
        if client_name then
            lsp_buf_rename(client_name)
            return
        end
        if fallback then
            fallback()
        end
    end
    vim.ui.select(client_names, { prompt = prompt }, on_choice)
end

local function lsp_buf_rename_use_priority_or_select()
    lsp_buf_rename_use_one(function()
        lsp_buf_rename_use_select()
    end)
end

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    -- list any phrases you want to block from code actions (case‐insensitive)
    local bannedPhrases = {
        "convert named import",
        "convert named export",
        "move to a new file",
        "generate 'get'",
        "add missing import",
    }

    nmap("<leader>ca", function()
        vim.lsp.buf.code_action({
            filter = function(action)
                local title = action.title:lower()
                for _, phrase in ipairs(bannedPhrases) do
                    if title:match(phrase) then
                        return false
                    end
                end
                return true
            end,
        })
    end, "[C]ode [A]ction")

    if client.name == "biome" then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("BiomeFixAll", { clear = true }),
            callback = function()
                vim.lsp.buf.code_action({
                    context = {
                        ---@diagnostic disable-next-line: assign-type-mismatch it works
                        only = { "source.fixAll.biome" },
                        diagnostics = {},
                    },
                    apply = true,
                })
            end,
        })
    end

    nmap("<leader>rn", lsp_buf_rename_use_priority_or_select, "[R]e[n]ame")

    local tsb = require("telescope.builtin")
    nmap("gd", tsb.lsp_definitions, "[G]oto [D]efinition") -- jumps directly if only one is found
    nmap("gr", tsb.lsp_references, "[G]oto [R]eferences")
    nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("<leader>ts", vim.lsp.buf.type_definition, "[T]ype [D]efinition")
    nmap("<leader>ds", tsb.lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", tsb.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- not tested
    nmap("<leader>cd", vim.lsp.codelens.display, "[C]ode Lens [D]isplay")
    nmap("<leader>cl", vim.lsp.codelens.refresh, "[C]ode [L]ens Refresh")
    nmap("<leader>cr", vim.lsp.codelens.run, "[C]ode Lens [R]un")

    -- See `:help K` for why this keymap
    nmap("<leader>k", function()
        vim.lsp.buf.hover({ border = "rounded", title = " hover " })
    end, "Hover Documentation")
    nmap("<leader>K", vim.lsp.buf.typehierarchy, "Type Hierarchy")
    vim.keymap.set(
        { "n", "i" },
        "<C-K>",
        vim.lsp.buf.signature_help,
        { desc = "Signature Documentation" }
    )

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        -- debug
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")
end

-- Toggle auto format
-- Format(Enable|Disable)
-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md
vim.api.nvim_create_user_command("FormatDisable", function(args)
    if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
    else
        vim.g.disable_autoformat = true
    end
end, {
    desc = "Disable autoformat-on-save",
    bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
end, {
    desc = "Re-enable autoformat-on-save",
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = on_attach,
})

for server_name, config in pairs(servers) do
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
end

-- zls is not downloaded by Mason, I want to control the version.
-- So, get it with a nix flake or `zvm` (zvm i -D=zls master)
vim.lsp.config("zls", {
    root_markers = { "zls.json", "build.zig", ".git" },
    workspace_required = false,
    cmd = { "zls" },
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "zig", "zir" },
    settings = {
        zls = {
            warn_style = true,
            enable_autofix = true,
            highlight_global_var_declarations = true,
        },
    },
})
vim.lsp.enable("zls")

-- still needed for the custom config, idk why
require("lspconfig").eslint.setup({
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        if client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "EslintFixAll",
            })
        end
    end,
})

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                cmp.complete()
            end
        end,
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-y>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-k>"] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-j>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        -- too slow
        -- { name = "rg" },
        { name = "buffer" },
        { name = "cmp-tw2css" },
        {
            name = "spell",
            option = {
                keep_all_entries = false,
                enable_in_context = function()
                    return require("cmp.config.context").in_treesitter_capture("spell")
                end,
                preselect_correct_word = true,
            },
        },
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
})

-- custom snippets
local s = luasnip.snippet
local i = luasnip.insert_node
local t = luasnip.text_node
local f = luasnip.function_node
local d = luasnip.dynamic_node
local c = luasnip.choice_node
local sn = luasnip.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

function get_date()
    return os.date("%Y-%m-%d")
end

-- Signature snippet
luasnip.add_snippets("all", {
    s("sign", {
        t({ "/**", " * Author: Sekky61", " * Date: " }),
        f(get_date, {}),
        t({ "", " * File: " }),
        f(function(_, snip)
            return snip.env.TM_FILENAME
        end, {}),
        t({ "", " * Description: " }),
        i(1),
        t({ "", " */" }),
    }),
})

-- Angular
local function typearg(
    args, -- text from i(2) in this example i.e. { { "456" } }
    parent, -- parent snippet or parent node
    user_args -- user_args from opts.user_args
)
    return args[1][1]
end

local function default_type(args, _parent, _old_state, user_args)
    local name = args[1][1]

    -- allow override via user_arg.default_type, fallback to "string"
    local fallback = (user_args and user_args.fallback_type) or "string"
    print("DEBUG: bool_match =", vim.inspect(user_args))
    -- detect boolean prefixes
    local prefix = name:match("^is")
        or name:match("^has")
        or name:match("^should")
        or name:match("^can")

    local inferred
    if prefix then
        inferred = "boolean"
    elseif name:match("[Nn]um$") or name:match("[Cc]ount$") then
        inferred = "number"
    else
        inferred = fallback
    end

    return sn(nil, { i(1, inferred) })
end

local function default_value(args, _parent, _old_state, _user_arg)
    local type_str = args[1][1]
    local val = type_str == "boolean" and "false"
        or type_str:find("undefined") and "undefined"
        or type_str:find("null") and "null"
        or "''"
    return sn(nil, { i(1, val) })
end

luasnip.add_snippets("typescript", {
    -- Computed Signal snippet
    s("computed", {
        t("protected readonly "),
        i(1, "foo"),
        t("Signal: Signal<"),
        d(2, default_type, { 1 }),
        t("> = computed"),
        t({ "(() => {", "" }),
        i(3, "  return "),
        d(3, default_value, { 2 }),
        t({ ";", "});" }),
    }),

    -- Signal snippet (general signal)
    s("signal", {
        t("protected readonly "),
        i(1, "foo"),
        t("Signal: WritableSignal<"),
        d(2, default_type, { 1 }),
        t("> = signal"),
        t("("),
        d(3, default_value, { 2 }),
        t(");"),
    }),

    -- Input signal
    s("inputsignal", {
        t("readonly "),
        i(1, "foo"),
        t("Signal: InputSignal<"),
        d(2, default_type, { 1 }),
        t("> = input"),
        t("("),
        d(3, default_value, { 2 }),
        t(", { alias: '"),
        f(typearg, { 1 }),
        t("' });"),
    }),

    -- Output signal
    s("outputsignal", {
        t("readonly "),
        i(1, "foo"),
        t(": OutputEmitterRef<"),
        d(2, default_type, { 1 }, { user_args = { fallback_type = "void" } }), -- todo fallback does not work
        t("> = output();"),
    }),

    -- Linked signal
    s("linkedsignal", {
        t("protected readonly "),
        i(1, "foo"),
        t("Signal: Signal<"),
        i(2, "string"),
        t("> = linkedSignal"),
        t({ "(() => {", "" }),
        i(3, "  return "),
        d(4, default_value, { 2 }),
        t({ ";", "});" }),
    }),

    -- Inject
    -- private readonly generalTrainerRolesApiService: GeneralTrainerRolesApiService = inject(GeneralTrainerRolesApiService);
    s("inject", {
        t("private readonly "),
        i(1, "foo"),
        t(": "),
        i(2, "Service"),
        t(" = inject("),
        f(typearg, { 2 }),
        t(");"),
    }),

    s("enumobj", {
        t("type "),
        i(1, "MyEnum"),
        t("Value = EnumObjectValue<typeof "),
        f(typearg, { 1 }),
        t(">;"),
        t({ "", "", "export const " }),
        f(typearg, { 1 }),
        t(" = {"),
        t({ "", "  " }),
        i(2),
        t({ "", "} as const;", "" }),
        i(0),
    }),

    s("ngif", {
        t("@if ("),
        i(1, "condition"),
        t({ ") {", "  " }),
        i(2, "<div></div>"),
        t({ "", "}" }),
        i(0),
    }),

    s("tapconsole", {
        t("tap(o => console.log('tap o', o)),"),
    }),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "nvim_lsp_document_symbol" }, -- you must start with `/@` for it to show up
    }, {
        { name = "buffer" },
    }),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
    matching = { disallow_symbol_nonprefix_matching = false },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- indent-blankline
vim.opt.list = true
vim.opt.listchars:append("space:⋅")

-- color the indent
vim.cmd([[highlight IndentBlanklineIndent1 guifg=#8a8686 gui=nocombine]])

-- Avante proompts

-- prefil edit window with common scenarios to avoid repeating query and submit immediately
local prefill_edit_window = function(request)
    require("avante.api").edit()
    local code_bufnr = vim.api.nvim_get_current_buf()
    local code_winid = vim.api.nvim_get_current_win()
    if code_bufnr == nil or code_winid == nil then
        return
    end
    vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
    -- Optionally set the cursor position to the end of the input
    vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
    -- Simulate Ctrl+S keypress to submit
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-s>", true, true, true), "v", true)
end

-- NOTE: most templates are inspired from ChatGPT.nvim -> chatgpt-actions.json
local avante_grammar_correction =
    "Correct the text to standard English, but keep any code blocks inside intact."
local avante_keywords = "Extract the main keywords from the following text"
local avante_code_readability_analysis = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Very obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Inconsistent naming
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
]]
local avante_optimize_code = "Optimize the following code"
local avante_summarize = "Summarize the following text"
local avante_translate = "Translate this into english, but keep any code blocks inside intact"
local avante_explain_code = "Explain the unobvious parts of the following code"
local avante_complete_code = "Complete the following codes written in " .. vim.bo.filetype
local avante_document_function = "Add documentation to the following function"
local avante_fix_bugs =
    "Fix the bugs inside the following codes if any. Make a note about the bugfix"
local avante_add_tests = "Implement simple but robust tests for the following code"

local wk = require("which-key")
wk.add({
    { "<leader>a", group = "Avante" }, -- NOTE: add for avante.nvim
    {
        mode = { "n", "v" },
        {
            "<leader>ag",
            function()
                require("avante.api").ask({ question = avante_grammar_correction })
            end,
            desc = "Grammar Correction(ask)",
        },
        {
            "<leader>ak",
            function()
                require("avante.api").ask({ question = avante_keywords })
            end,
            desc = "Keywords(ask)",
        },
        {
            "<leader>al",
            function()
                require("avante.api").ask({ question = avante_code_readability_analysis })
            end,
            desc = "Code Readability Analysis(ask)",
        },
        {
            "<leader>ao",
            function()
                require("avante.api").ask({ question = avante_optimize_code })
            end,
            desc = "Optimize Code(ask)",
        },
        {
            "<leader>am",
            function()
                require("avante.api").ask({ question = avante_summarize })
            end,
            desc = "Summarize text(ask)",
        },
        {
            "<leader>an",
            function()
                require("avante.api").ask({ question = avante_translate })
            end,
            desc = "Translate text(ask)",
        },
        {
            "<leader>ax",
            function()
                require("avante.api").ask({ question = avante_explain_code })
            end,
            desc = "Explain Code(ask)",
        },
        {
            "<leader>ac",
            function()
                require("avante.api").ask({ question = avante_complete_code })
            end,
            desc = "Complete Code(ask)",
        },
        {
            "<leader>ad",
            function()
                require("avante.api").ask({ question = avante_document_function })
            end,
            desc = "Document function(ask)",
        },
        {
            "<leader>ab",
            function()
                require("avante.api").ask({ question = avante_fix_bugs })
            end,
            desc = "Fix Bugs(ask)",
        },
        {
            "<leader>au",
            function()
                require("avante.api").ask({ question = avante_add_tests })
            end,
            desc = "Add Tests(ask)",
        },
    },
})

wk.add({
    { "<leader>a", group = "Avante" }, -- NOTE: add for avante.nvim
    {
        mode = { "v" },
        {
            "<leader>aG",
            function()
                prefill_edit_window(avante_grammar_correction)
            end,
            desc = "Grammar Correction",
        },
        {
            "<leader>aK",
            function()
                prefill_edit_window(avante_keywords)
            end,
            desc = "Keywords",
        },
        {
            "<leader>aO",
            function()
                prefill_edit_window(avante_optimize_code)
            end,
            desc = "Optimize Code(edit)",
        },
        {
            "<leader>aC",
            function()
                prefill_edit_window(avante_complete_code)
            end,
            desc = "Complete Code(edit)",
        },
        {
            "<leader>aD",
            function()
                prefill_edit_window(avante_document_function)
            end,
            desc = "Document function(edit)",
        },
        {
            "<leader>aB",
            function()
                prefill_edit_window(avante_fix_bugs)
            end,
            desc = "Fix Bugs(edit)",
        },
        {
            "<leader>aU",
            function()
                prefill_edit_window(avante_add_tests)
            end,
            desc = "Add Tests(edit)",
        },
    },
})

-- debug/dev

-- Pretty print
P = function(v)
    print(vim.inspect(v))
    return v
end

RELOAD = function(...)
    return require("plenary.reload").reload_module(...)
end

-- Reload
R = function(name)
    RELOAD(name)
    return require(name)
end

--theme
vim.cmd.colorscheme("catppuccin-frappe")

-- jump to the context (the line on top) when in one
vim.keymap.set("n", "[k", function()
    require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Jump to previous context" })

-- Move current line up
vim.api.nvim_set_keymap("n", "<A-up>", ":m-2<CR>==", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-up>", "<Esc>:m-2<CR>==gi", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<A-up>", ":m-2<CR>gv=gv", { noremap = true, silent = true })

-- Move current line down
vim.api.nvim_set_keymap("n", "<A-Down>", ":m+<CR>==", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-Down>", "<Esc>:m+<CR>==gi", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<A-Down>", ":m'>+<CR>gv=gv", { noremap = true, silent = true })

-- Toggle nvimtree
vim.keymap.set("n", "<leader>tt", ":NvimTreeToggle<CR>", { desc = "Toggle nvimtree" })
-- toggle history tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })

-- half page up and down with zz
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- paste over without yanking
vim.keymap.set("x", "<leader>p", '"_dP')

-- unmap Q
vim.keymap.set("n", "Q", "<Nop>")

-- Git + Github
vim.api.nvim_set_keymap(
    "n",
    "<leader>gp",
    ":Git push -u origin HEAD<CR>",
    { noremap = false, desc = "Git Push" }
)

vim.keymap.set("n", "[q", ":cprev<CR>", { desc = "Jump to previous quickfix entry" })
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Jump to next quickfix entry" })

vim.keymap.set(
    "n",
    "<leader>cb",
    "<cmd>%bd|e#<cr>",
    { desc = "[C]lose all [b]uffers but the current one" }
) -- https://stackoverflow.com/a/42071865/516188

-- Work

local function table_convert_popup()
    local input = vim.fn.input("Enter type name: ")
    if input == "" then
        return
    end

    -- Get the selected text
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_pos[2] - 1, end_pos[2], false)
    print("lines ")
    P(start_pos)
    P(end_pos)
    P(lines)

    local result = {}
    for i = 3, #lines do -- skip header rows
        local prop, dtype, nullable =
            lines[i]:match("|%s*`(.-)`%s*|%s*<DataType type='(.-)'(%s+nullable)? />")
        print("prop")
        print(prop)
        print(dtype)
        if prop and dtype then
            local js_types = {
                Int = "number",
                String = "string",
                Boolean = "boolean",
            }
            local js_type = js_types[dtype] or "any"
            local nullable = nullable_s == "nullable"
            local create = nullable and "@FieldCreate()\n" or ""
            table.insert(
                result,
                string.format("  @Field()\n%s  [%sProperty.%s]!:%s;", create, input, prop, js_type)
            )
        end
    end
    P(result)

    -- Insert at cursor position
    -- vim.api.nvim_buf_set_lines(bufnr, start_pos[2] - 1, end_pos[2], false, result)
    vim.fn.setreg('"', table.concat(result, "\n")) -- copy to clipboard
    print("Converted class properties in clipboard")
end

vim.api.nvim_create_user_command("ConvertModelTable", table_convert_popup, {})
vim.keymap.set({ "n", "v" }, "<leader>ct", table_convert_popup, { expr = true })
