-- This file will be inlined into home-manager initial configuration
-- globals
local api = vim.api
local map = vim.keymap.set
local global_opt = vim.opt_global
local diag = vim.diagnostic

global_opt.clipboard = "unnamed"
global_opt.timeoutlen = 200

-- <CTRL> + a and <CTRL> + e move to the beginning and the end of the line
map("c", "<C-a>", "<HOME>", { noremap = true })
map("c", "<C-e>", "<END>", { noremap = true })
-- }

map("n", "<F11>", ":wall<CR>", { noremap = true, silent = true })

require("which-key").setup()

require("nvim-autopairs").setup({
    check_ts = true,
})


require("Comment").setup()

require("neoclip").setup()
require("telescope").load_extension("neoclip")
map("n", '<leader>"', require("telescope").extensions.neoclip.star, { desc = "clipboard" })

require("indent_blankline").setup()

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup({
    view = {
        adaptive_size = true,
    },
})
map("n", '<leader>et', function()
    require("nvim-tree.api").tree.toggle(true, true)
end, { desc = "nvim_tree toggle" })
map("n", '<leader>ef', function()
    require("nvim-tree.api").tree.find_file(false, true)
end, { desc = "nvim_tree toggle" })

local neogit = require('neogit')
neogit.setup {
    disable_commit_confirmation = true,
    integrations = {
        diffview = true
    }
}
map("n", '<leader>n', function()
    neogit.open()
end, { desc = "neogit" })


require("nvim-treesitter.configs").setup({
    ensure_installed = {},
    highlight = {
        enable = true, -- false will disable the whole extension                 -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
        disable = {}, -- treesitter interferes with VimTex
    },
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            node_decremental = "<BS>",
            scope_incremental = "<TAB>",
        },
    },
    textobjects = {
        enable = true,
        move = {
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
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
        select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                -- You can optionally set descriptions to the mappings (used in the desc parameter of
                -- nvim_buf_set_keymap) which plugins like which-key display
                ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                -- You can also use captures from other query groups like `locals.scm`
                ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V',  -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
            include_surrounding_whitespace = true,
        },
    }
})
