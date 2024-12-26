-- Neovim config. Michal Majer

-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader          = ' '
vim.g.maplocalleader     = ' '

vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath           = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- import plugins
require('lazy').setup({
  -- Git related plugins
  'tpope/vim-rhubarb',
  "https://tpope.io/vim/fugitive.git",

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',

      -- Adds words from buffer to completion list
      'hrsh7th/cmp-buffer',

      -- cmdline
      'hrsh7th/cmp-cmdline',

      -- Spelling
      'f3fora/cmp-spell'
    },
  },

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
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          opts = opts or {}
          opts.buffer = bufnr
          opts.desc = desc
          vim.keymap.set(mode, l, r, opts)
        end

        vim.keymap.set('n', '[h', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = 'Go to Previous [C]hange' })
        vim.keymap.set('n', ']h', require('gitsigns').next_hunk, { buffer = bufnr, desc = 'Go to Next [C]hange' })
        vim.keymap.set('n', '<leader>pc', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = '[P]review [C]hange' })
        vim.keymap.set('n', '<leader>tB', gs.toggle_current_line_blame, { buffer = bufnr, desc = 'Toggle [B]lame' })
        map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', 'Stage hunk')
        map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', 'Reset hunk')
        map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
        map('n', '<leader>ha', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
        map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')
        map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>hb', function() gs.blame_line { full = true } end, 'Blame line')
        map('n', '<leader>hd', gs.diffthis, 'Diff hunk')
        map('n', '<!-- <leader> -->hD', function() gs.diffthis('~') end)
      end,
    },
  },

  -- Theme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {
      indent = {
        highlight = {
          "CursorColumn",
          "Whitespace",
        },
        char = ""
      },
      whitespace = {
        highlight = {
          "CursorColumn",
          "Whitespace",
        },
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
    }
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      "debugloop/telescope-undo.nvim",
      {
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
        local ts = require('telescope')
        local ts_undo = require('telescope-undo.actions')
        local processes_picker = require('telescope-processes')
        
        local h_pct = 0.90
        local w_pct = 0.80
        local w_limit = 75
        local standard_setup = {
            borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
            preview = { hide_on_startup = true },
            layout_strategy = 'vertical',
            layout_config = {
                vertical = {
                    mirror = true,
                    prompt_position = 'top',
                    width = function(_, cols, _)
                        return math.min( math.floor( w_pct * cols ), w_limit )
                    end,
                    height = function(_, _, rows)
                    return math.floor( rows * h_pct )
                    end,
                    preview_cutoff = 10,
                    preview_height = 0.4,
                },
            },
        }
        local fullscreen_setup = {
            borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
            preview = { hide_on_startup = false },
            layout_strategy = 'flex',
            layout_config = {
                flex = { flip_columns = 100 },
                horizontal = {
                    mirror = false,
                    prompt_position = 'top',
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
                    prompt_position = 'top',
                    width = function(_, cols, _)
                        return math.floor(cols * w_pct)
                    end,
                    height = function(_, _, rows)
                        return math.floor(rows * h_pct)
                    end,
                    preview_cutoff = 10,
                    preview_height = 0.5,
                },
            },
        }
        ts.setup {
            defaults = vim.tbl_extend('error', fullscreen_setup, {
                sorting_strategy = 'ascending',
                path_display = { "filename_first" },
                mappings = {
                    -- <C-/> to see all binds
                    -- <C-t> to open in new tab
                    -- <C-x> to open in split
                    -- <C-v> to open in vsplit
                    n = {
                        ['o'] = require('telescope.actions.layout').toggle_preview,
                        ['<C-c>'] = require('telescope.actions').close,
                    },
                    i = {
                        ['<C-h>'] = require('telescope.actions.layout').toggle_preview,
                    },
                },
            }),
            pickers = {
                find_files = {
                    find_command = {
                        'fd', '--type', 'f', '-H', '--strip-cwd-prefix',
                    }
                },
            },
            extensions = {
                ["ui-select"] = {
                  require("telescope.themes").get_dropdown {
                    -- even more opts
                  },
                },
                undo = vim.tbl_extend('error', fullscreen_setup, {
                    vim_context_lines = 4,
                    preview_title = "Diff",
                    mappings = {
                        i = {
                            ['<cr>'] = ts_undo.restore,
                            ['<C-cr>'] = ts_undo.restore,
                            ['<C-y>d'] = ts_undo.yank_deletions,
                            ['<C-y>a'] = ts_undo.yank_additions,
                        },
                        n = {
                            ['<cr>'] = ts_undo.restore,
                            ['ya'] = ts_undo.yank_additions,
                            ['yd'] = ts_undo.yank_deletions,
                        },
                    },
                })
            }
        }
        ts.load_extension('fzf')
        ts.load_extension('undo')
        ts.load_extension("ui-select")

        -- See `:help telescope.builtin`
        local tsb = require('telescope.builtin')
        vim.keymap.set('n', '<leader>?', tsb.oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader><space>', tsb.buffers, { desc = '[ ] Find existing buffers' })
        vim.keymap.set('n', '<leader>/', tsb.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })

        -- <C-q>    Send all items not filtered to quickfixlist (qflist)
        -- combine with :cdo (apply command to all items in quickfix list)
        vim.keymap.set('n', '<leader>gf', tsb.git_files, { desc = 'Search [G]it [F]iles' })
        vim.keymap.set('n', '<leader>sf', tsb.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>sh', tsb.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sw', tsb.grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', tsb.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', tsb.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>ss', tsb.git_status, { desc = '[S]earch [S]tatus' })
        vim.keymap.set('n', '<leader>sc', tsb.commands, { desc = '[S]earch [C]ommands' })
        vim.keymap.set('n', '<leader>s=', tsb.spell_suggest, { desc = '[S]earch Spelling' })
        vim.keymap.set('n', '<leader>sk', tsb.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>sm', function()
          tsb.builtin({ include_extensions = true })
        end, { desc = '[S]earch [M]enu' })

        vim.keymap.set('n', '<leader>sc', function()
          require('telescope.builtin').find_files({
            cwd = vim.fn.expand('%:p:h')
          })
        end, { desc = '[S]earch from [C]urrent dir' })

        -- see treesitter symbols
        vim.keymap.set('n', '<leader>sv', tsb.treesitter, { desc = '[S]earch [V]ariables (Treesitter Symbols)' })
        vim.keymap.set('n', '<leader>sp', processes_picker.list_processes, { desc = '[S]earch [P]rocesses' })

        -- undo
        vim.keymap.set("n", "<leader>su", "<cmd>Telescope undo<cr>", { desc = '[S]earch [U]udo' })

    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
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
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    lazy = false,
  },
  {
    'kosayoda/nvim-lightbulb',
    opts = {
      autocmd = { enabled = true },
      number = {
        enabled = true,
      },
    }
  },
  {
    -- Session management. <leader>sm and "session" to get menu of all sessions
    'rmagatti/auto-session',
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { '~/', '~/Documents', '~/Downloads', '/' },
    }
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

  -- efm language server
  {
    'creativenull/efmls-configs-nvim',
    version = 'v1.x.x', -- version is optional, but recommended
    dependencies = { 'neovim/nvim-lspconfig' },
  },

  {
    -- treesitter context (function header visible on top)
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20,     -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    }
  },
  -- history tree
  'mbbill/undotree',
  -- completions for command line
  'hrsh7th/cmp-cmdline',
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
  { "Bilal2453/luvit-meta",    lazy = true }, -- optional `vim.uv` typings
  {
    -- LLM
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
      provider = "groq",
      vendors = {
        groq = {
          __inherited_from = "openai",
          api_key_name = "GROQ_API_KEY",
          endpoint = "https://api.groq.com/openai/v1/",
          model = "llama-3.3-70b-versatile",
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
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
        'MeanderingProgrammer/render-markdown.nvim',
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
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
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
      local dap = require "dap"
      local ui = require "dapui"

      require("dapui").setup()
      require("dap-go").setup()

      require("nvim-dap-virtual-text").setup {}

      vim.keymap.set("n", "<leader>bb", dap.toggle_breakpoint, { desc = "Toggle [B]reakpoint" })
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

      local js_based_languages = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }
      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          -- ...
          {
            name = 'Next.js: debug server-side',
            type = 'node2',
            request = 'attach',
            port = 9231,
            skipFiles = { '<node_internals>/**', 'node_modules/**' },
            cwd = '${workspaceFolder}',
          },
          -- ...
        }
      end

      local make_lldb_config = function (language)
        return {
          {
            type = 'codelldb',
            name = 'Launch ' .. language .. ' program by path',
            request = 'launch',
            program = '${command:pickFile}',
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = {},
            runInTerminal = false,
          },

          {
            type = 'codelldb',
            name = 'Attach to ' .. language .. ' program',
            request = 'attach',
            pid = "${command:pickProcess}",
            port = 7000,
          }

        }
      end
      local lldb_langs = { 'c', 'cpp', 'rust', 'zig', 'go' }

      for _, lang in ipairs(lldb_langs) do
        dap.configurations[lang] = make_lldb_config(lang)
      end

    end,
  },
  "jay-babu/mason-nvim-dap.nvim",
  "williamboman/mason.nvim",
  -- { dir = "~/Documents/lsp-sample-extractor.nvim", opts = {} }   -- my experiment

}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- set the bottom safe area
vim.opt.scrolloff = 8

vim.opt.tabstop = 4

-- Draw a line at the 80th character
vim.opt.colorcolumn = '80'

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- spell checking requires
-- z= or <leader>s= for suggestions
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'html', 'javascript', 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'zig', 'typescript', 'vimdoc', 'vim',
    'json', 'yaml', 'toml', 'css', 'tsx', 'csv', 'diff', 'dockerfile', 'bash', 'markdown', 'nix'
  },
  sync_install = false,

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = true,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    -- peek definition with treesitter
    lsp_interop = {
      enable = true,
      border = 'none',
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
        ['ap'] = '@parameter.outer',
        ['ip'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']f'] = '@function.outer',
        [']]'] = '@class.outer',
        ["]o"] = "@loop.*",
        ["]c"] = "@conditional.outer",
        ["]b"] = "@block.outer",
        ["]s"] = "@statement.outer",
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[['] = '@class.outer',
        ["[o"] = "@loop.*",
        ["[c"] = "@conditional.outer",
        ["[b"] = "@block.outer",
        ["[s"] = "@statement.outer",
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Make treesitter motions repeatable with ; and ,
local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

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


-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' }) -- use <leader>xx instead

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = '[G]oto [D]efinition' }) -- jumps directly if only one is found
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('<leader>k', vim.lsp.buf.hover, 'Hover Documentation')
  vim.keymap.set({'n', 'i'}, '<C-K>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
  nmap('<leader>f', function()
    MyFormat()
  end, '[F]ormat')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    MyFormat()
  end, { desc = 'Format current buffer with LSP' })
end

-- custom format function
function MyFormat()
  vim.lsp.buf.format {
    async = true,
    filter = function(client) return client.name ~= "tsserver" end
  }
end

-- DAP

require("mason").setup()
require("mason-nvim-dap").setup({
  -- launguages, not adapter names
  -- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
  ensure_installed = { "bash", "codelldb", "python", "cppdbg", "js", "javadbg", "node2" },
  automatic_installation = true,
  handlers = {}, -- The defaults
  adapters = {
    codelldb = {
      type = 'server',
      host = '127.0.0.1',
      port = 13000 -- 💀 Use the port printed out or specified with `--port`
    },
  },
})

-- Enable the following language servers
-- Link: https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
local servers = {

  clangd = {},
  pyright = {},
  rust_analyzer = {},
  jsonls = {},
  nil_ls = {}, -- nix
  gopls = {},
  omnisharp = {},

  html = { filetypes = { 'html', 'twig', 'hbs' } },
  custom_elements_ls = {},
  cssls = { filetypes = { 'scss', 'less', 'stylus', 'css' } },
  tailwindcss = {},
  ts_ls = {}, -- wraps tsserver
  biome = {},
  astro = {},
  emmet_ls = {
    filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue" },
  },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },

}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- To update: zvm i -D=zls master
-- It is OS dependent right now
require('lspconfig').zls.setup {
  cmd = { 'zls' },
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'zig' },
  settings = {
    zls = {
      zig_exe_path = '~/.zvm/bin/zig',
      warn_style = true,
      enable_autofix = true,
      highlight_global_var_declarations = true,
    }
  }
}

local bashate = require('efmls-configs.linters.bashate')
local languages = {
  bash = { bashate },
}

local lsp_fmt_group = vim.api.nvim_create_augroup('LspFormattingGroup', {})
vim.api.nvim_create_autocmd('BufWritePost', {
  group = lsp_fmt_group,
  callback = function(ev)
    local efm = vim.lsp.get_active_clients({ name = 'efm', bufnr = ev.buf })

    if vim.tbl_isempty(efm) then
      return
    end

    vim.lsp.buf.format({ name = 'efm' })
  end,
})

local efmls_config = {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { '.git/' },
    languages = languages,
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
}

require('lspconfig').efm.setup(vim.tbl_extend('force', efmls_config, {
  -- Pass your custom lsp config below like on_attach and capabilities
  --
  -- on_attach = on_attach,
  -- capabilities = capabilities,
}))

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        cmp.complete()
      end
    end,
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-y>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-j>'] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    {
      name = "spell",
      option = {
        keep_all_entries = false,
        enable_in_context = function()
          return require('cmp.config.context').in_treesitter_capture('spell')
        end,
        preselect_correct_word = true,
      },
    },
  },
}

-- custom snippets
local s = luasnip.snippet
local i = luasnip.insert_node
local t = luasnip.text_node
local f = luasnip.function_node
local fmt = require("luasnip.extras.fmt").fmt

function get_date()
  return os.date("%Y-%m-%d")
end

-- Signature snippet
luasnip.add_snippets("all", {
  s("sign", {
    t({ "/**", " * Author: Sekky61", " * Date: " }), f(get_date, {}),
    t({ "", " * File: " }), f(function(_, snip) return snip.env.TM_FILENAME end, {}),
    t({ "", " * Description: " }), i(1),
    t({ "", " */" }),
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
    { name = 'path' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- indent-blankline
vim.opt.list = true
vim.opt.listchars:append "space:⋅"

-- color the indent
vim.cmd [[highlight IndentBlanklineIndent1 guifg=#8a8686 gui=nocombine]]

-- Avante proompts

-- prefil edit window with common scenarios to avoid repeating query and submit immediately
local prefill_edit_window = function(request)
  require('avante.api').edit()
  local code_bufnr = vim.api.nvim_get_current_buf()
  local code_winid = vim.api.nvim_get_current_win()
  if code_bufnr == nil or code_winid == nil then
    return
  end
  vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
  -- Optionally set the cursor position to the end of the input
  vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
  -- Simulate Ctrl+S keypress to submit
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, true, true), 'v', true)
end

-- NOTE: most templates are inspired from ChatGPT.nvim -> chatgpt-actions.json
local avante_grammar_correction = 'Correct the text to standard English, but keep any code blocks inside intact.'
local avante_keywords = 'Extract the main keywords from the following text'
local avante_code_readability_analysis = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Redundant or obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Long variable names
  - Inconsistent naming and code style.
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
]]
local avante_optimize_code = 'Optimize the following code'
local avante_summarize = 'Summarize the following text'
local avante_translate = 'Translate this into Chinese, but keep any code blocks inside intact'
local avante_explain_code = 'Explain the following code'
local avante_complete_code = 'Complete the following codes written in ' .. vim.bo.filetype
local avante_add_docstring = 'Add docstring to the following codes'
local avante_fix_bugs = 'Fix the bugs inside the following codes if any'
local avante_add_tests = 'Implement tests for the following code'

local wk = require('which-key');
wk.add({
  { '<leader>a', group = 'Avante' }, -- NOTE: add for avante.nvim
  {
    mode = { 'n', 'v' },
    {
      '<leader>ag',
      function()
        require('avante.api').ask { question = avante_grammar_correction }
      end,
      desc = 'Grammar Correction(ask)',
    },
    {
      '<leader>ak',
      function()
        require('avante.api').ask { question = avante_keywords }
      end,
      desc = 'Keywords(ask)',
    },
    {
      '<leader>al',
      function()
        require('avante.api').ask { question = avante_code_readability_analysis }
      end,
      desc = 'Code Readability Analysis(ask)',
    },
    {
      '<leader>ao',
      function()
        require('avante.api').ask { question = avante_optimize_code }
      end,
      desc = 'Optimize Code(ask)',
    },
    {
      '<leader>am',
      function()
        require('avante.api').ask { question = avante_summarize }
      end,
      desc = 'Summarize text(ask)',
    },
    {
      '<leader>an',
      function()
        require('avante.api').ask { question = avante_translate }
      end,
      desc = 'Translate text(ask)',
    },
    {
      '<leader>ax',
      function()
        require('avante.api').ask { question = avante_explain_code }
      end,
      desc = 'Explain Code(ask)',
    },
    {
      '<leader>ac',
      function()
        require('avante.api').ask { question = avante_complete_code }
      end,
      desc = 'Complete Code(ask)',
    },
    {
      '<leader>ad',
      function()
        require('avante.api').ask { question = avante_add_docstring }
      end,
      desc = 'Docstring(ask)',
    },
    {
      '<leader>ab',
      function()
        require('avante.api').ask { question = avante_fix_bugs }
      end,
      desc = 'Fix Bugs(ask)',
    },
    {
      '<leader>au',
      function()
        require('avante.api').ask { question = avante_add_tests }
      end,
      desc = 'Add Tests(ask)',
    },
  },
});

wk.add({
  { '<leader>a', group = 'Avante' }, -- NOTE: add for avante.nvim
  {
    mode = { 'v' },
    {
      '<leader>aG',
      function()
        prefill_edit_window(avante_grammar_correction)
      end,
      desc = 'Grammar Correction',
    },
    {
      '<leader>aK',
      function()
        prefill_edit_window(avante_keywords)
      end,
      desc = 'Keywords',
    },
    {
      '<leader>aO',
      function()
        prefill_edit_window(avante_optimize_code)
      end,
      desc = 'Optimize Code(edit)',
    },
    {
      '<leader>aC',
      function()
        prefill_edit_window(avante_complete_code)
      end,
      desc = 'Complete Code(edit)',
    },
    {
      '<leader>aD',
      function()
        prefill_edit_window(avante_add_docstring)
      end,
      desc = 'Docstring(edit)',
    },
    {
      '<leader>aB',
      function()
        prefill_edit_window(avante_fix_bugs)
      end,
      desc = 'Fix Bugs(edit)',
    },
    {
      '<leader>aU',
      function()
        prefill_edit_window(avante_add_tests)
      end,
      desc = 'Add Tests(edit)',
    },
  },
});

-- debug/dev

-- Pretty print
P = function (v)
  print(vim.inspect(v))
  return v
end

RELOAD = function (...)
  return require("plenary.reload").reload_module(...)
end

-- Reload
R = function (name)
  RELOAD(name)
  return require(name)
end

--theme
vim.cmd.colorscheme "catppuccin-frappe"

-- jump to the context when in one
vim.keymap.set("n", "[k", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Jump to previous context" })

vim.keymap.set("n", "]g", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })

-- Move current line up
vim.api.nvim_set_keymap('n', '<A-up>', ':m-2<CR>==', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-up>', '<Esc>:m-2<CR>==gi', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<A-up>', ':m-2<CR>gv=gv', { noremap = true, silent = true })

-- Move current line down
vim.api.nvim_set_keymap('n', '<A-Down>', ':m+<CR>==', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-Down>', '<Esc>:m+<CR>==gi', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<A-Down>', ':m\'>+<CR>gv=gv', { noremap = true, silent = true })

-- Toggle nvimtree
vim.keymap.set("n", "<leader>tt", ":NvimTreeToggle<CR>", { desc = "Toggle nvimtree" })
-- toggle history tree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })

-- half page up and down with zz
vim.api.nvim_set_keymap('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })

-- paste over without yanking
vim.keymap.set('x', '<leader>p', '"_dP')

-- unmap Q
vim.keymap.set('n', 'Q', '<Nop>')

-- Git
vim.api.nvim_set_keymap("n", "<leader>gc", ":Git commit -m \"", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>gp", ":Git push -u origin HEAD<CR>", { noremap = false })
