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

vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = { 'cp932', 'utf-8', 'euc-jp' }

-- C/C++ファイルは常にcp932で保存
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
   pattern = { "*.c", "*.cpp", "*.h" },
   callback = function()
      vim.bo.fileencoding = "cp932"
      vim.opt_local.cindent = true
      vim.opt_local.smartindent = false
      vim.opt_local.cinoptions = ":0s"
   end
})

-- vifmrc filetype
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
   pattern = "vifmrc",
   callback = function()
      vim.bo.filetype = "vim"
   end,
})
-- syntax on
vim.cmd("syntax enable")
vim.cmd.colorscheme "terafox"

-- value setting
local my_python           = os.getenv("MYPYTHON")
vim.g.python3_host_prog   = my_python
vim.g.EasyMotion_smatcase = 1

vim.diagnostic.config({ severity_sort = true })




-- フォールディングをexprに設定し、treesitterのfoldexprを使用
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false -- デフォルトでフォールドを開いた状態にする



vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.rs", "Cargo.toml"},
  callback = function()
    vim.bo.fileencoding = "utf-8"
  end,
})
