
-- ########## base set grp #############
local op = vim.opt

-- use system to clipboard
op.clipboard:append { "unnamedplus" }

-- nonuse to swapfile and backup
op.guifont     = "consolas:h10"
op.smartcase   = true
op.swapfile    = false
op.backup      = false
op.number      = false
op.smartindent = true
op.expandtab   = true
op.tabstop     = 3
op.softtabstop = 3
op.shiftwidth  = 3
op.title       = false
op.ignorecase  = true
op.shortmess:append "I"


-- コメントアウトの自動挿入を無効化
vim.api.nvim_command('autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o')

-- auto move current directory

op.autochdir = true

-- encoding
op.encoding = "utf-8"
op.fileencoding = "utf-8"

-- syntax on
vim.cmd("syntax enable")
vim.cmd.colorscheme "gruvbox"

-- value setting
local my_python = os.getenv("MYPYTHON")
vim.g.python3_host_prog = my_python
vim.g.EasyMotion_smatcase = 1

vim.diagnostic.config({severity_sort = true})


vim.api.nvim_create_autocmd("FileType", { pattern = "fern",
    callback = function()
        -- cキーでディレクトリをcd
        vim.api.nvim_buf_set_keymap(0, 'n', 'c', '<Plug>(fern-action-cd)', { noremap = false, silent = true })
    end,
})

