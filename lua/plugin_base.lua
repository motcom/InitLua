-- fileを開いた時に、そのディレクトリに移動する 
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
        if dir ~= "" then
            vim.cmd("cd " .. dir)
        end
    end,
})

-- minimap の設定
vim.g.minimap_width = 10

-- EasyMotionの<Leader><Leader>マッピングを無効化
vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_use_smartsign_us = 1

-- markdown previewの設定
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 0 
vim.g.mkdp_theme = "light"
vim.api.nvim_set_keymap("n", "<F4>", ":MarkdownPreviewToggle<CR>", { noremap = true, silent = true })
vim.g.plantuml_previewer_plantuml_jar_path = "plant_uml.jar"
-- インデントブランクラインの設定
require("ibl").setup()

-- 補完時の色
vim.cmd [[
  highlight Pmenu guibg=#3f2d2e guifg=#f0e6d2
  highlight PmenuSel guibg=#ffba69 guifg=#3f2d2e
  highlight PmenuSbar guibg=#2e1f1f
  highlight PmenuThumb guibg=#ffba69
  highlight CmpItemKind guifg=#e0af68
  highlight CmpItemAbbr guifg=#f0e6d2
  highlight CmpItemAbbrMatch guifg=#e06c75 gui=bold
  highlight CmpItemAbbrMatchFuzzy guifg=#e06c75 gui=italic
]]

-- カッコを自動で閉じる
require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt", "vim" },
  enable_check_bracket_line = true, -- 同じ行でのみ括弧を閉じる
})

require('nvim-treesitter.configs').setup {
   ensure_installed = {"lua","python","toml","json",
      "rust","markdown"},
   indent = {
      enable = true
   },
  highlight = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
   fold = {
      enable = true
   },
}

-- ZenModeの設定
local zen_mode = require("zen-mode")
zen_mode.setup({
  window = {
    backdrop = 0.85,
    width = 90,
    height = 1,
    options = {
      signcolumn = "no",
      number = false,
      relativenumber = false,
      cursorline = true,
      cursorcolumn = false,
      foldcolumn = "0",
      list = false,
    },
  },
  plugins = {
    twilight = { enabled = true },
  },
})
