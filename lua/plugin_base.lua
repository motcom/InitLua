
-- fern default hidden
vim.g["fern#default_hidden"] = 1

-- fileを開いた時に、そのディレクトリに移動する 
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local dir = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
        if dir ~= "" then
            vim.cmd("cd " .. dir)
        end
    end,
})

-- easy allign setting
vim.g.easy_align_ignore_groups = { 
    ["-"] = { pattern = "-\\{2,}" }
}

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

-- Telescope Seting
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Telescope diagnostics' })
vim.keymap.set('n', '<leader>fc', builtin.current_buffer_fuzzy_find, { desc = 'Telescope live grep current buffer' })
vim.keymap.set('n', '<leader>fm', builtin.lsp_document_symbols, { desc = 'Telescope method find' })
vim.keymap.set('n', '<leader>ft', builtin.treesitter, { desc = 'Telescope treesitter' })

