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


-- minimap の設定
vim.g.minimap_width = 10

-- EasyMotionの<Leader><Leader>マッピングを無効化
vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_use_smartsign_us = 1

-- markdown previewの設定
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 0
vim.g.mkdp_markdown_css = os.getenv("MYDATA") .. "/markdown.css"
vim.g.mkdp_theme = "dark"

vim.api.nvim_set_keymap("n", "<F3>", ":MarkdownPreviewToggle<CR>", { noremap = true, silent = true })

local plant_uml_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/plantuml-previewer.vim/lib/plantuml.jar"
vim.g.plantuml_previewer_plantuml_jar_path = plant_uml_path


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
   modules = {},
   sync_install = false,
   ignore_install = {},
   auto_install = true,
   ensure_installed = { "lua", "python", "json","toml","csv","rust","markdown" },
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
require("telescope").setup({
   defaults = {
      initial_mode = "normal"
   }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Telescope diagnostics' })
vim.keymap.set('n', '<leader>fc', builtin.current_buffer_fuzzy_find, { desc = 'Telescope live grep current buffer' })
vim.keymap.set('n', '<leader>fm', builtin.lsp_document_symbols, { desc = 'Telescope method find' })
vim.keymap.set('n', '<leader>ft', builtin.treesitter, { desc = 'Telescope treesitter' })


-- live server
vim.api.nvim_create_user_command("LiveServer", function()
   -- Neovim のターミナルを開き、live-server を実行
   vim.cmd("split | terminal live-server")
   -- 少し待ってからターミナルを閉じる（非同期で処理）
   vim.defer_fn(function()
      vim.cmd("q") -- ターミナルウィンドウを閉じる
   end, 1000)      -- 1秒 (1000ミリ秒) 待機してから閉じる
end, {})
vim.keymap.set('n', "<leader>p", ":LiveServer<CR>", { noremap = true, silent = true })

-- フォールディングをexprに設定し、treesitterのfoldexprを使用
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false -- デフォルトでフォールドを開いた状態にする



local function get_fern_selected_path()
   local win_id = vim.api.nvim_get_current_win()
   local path = vim.fn['fern#smart#leaf'](win_id)
   if path == "" then
      print("No file selected.")
   else
      print("Selected path: " .. path)
   end
end
-- コマンドとして登録
vim.api.nvim_create_user_command('FernPathLua', get_fern_selected_path, {})
vim.keymap.set('n', 'yp', ':FernPathLua<CR>', { noremap = true, silent = true })



require("nvim-autopairs").setup {}

-- doxygen comment
vim.keymap.set("n", "<Leader>df", function()
   require("neogen").generate()
end, { desc = "Generate Doxygen comment" })
