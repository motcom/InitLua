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


-- CSVViewの設定
require("csvview").setup({
   header = true,      -- ヘッダーを表示
   auto_detect = true, -- 自動でCSV形式を検出
   delimiter = ",",    -- デフォルトの区切り文字
   quote_char = '"',   -- デフォルトの引用符
   max_width = 100,    -- 最大列幅
})

-- EasyMotionの<Leader><Leader>マッピングを無効化
vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_use_smartsign_us = 1

-- markdown previewの設定
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 0
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
   ensure_installed = { "lua", "python", "json", "c_sharp", "csv", "markdown" },
   indent = {
      enable = true
   },
   highlight = {
      enable = true,
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
   },
   pickers = {
      buffers = {
         mappings = {
            i = {
               ["<c-d>"] = require('telescope.actions').delete_buffer,
            },
            n = {
               ["<c-d>"] = require('telescope.actions').delete_buffer,
            }
         }
      }
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

-- fern でカーソル下のファイルの絶対パスを推定して返す
local function fern_current_abs_path()
   if vim.bo.filetype ~= 'fern' or not vim.b.fern or not vim.b.fern.root or not vim.b.fern.root.bufname then
      return nil
   end
   -- fern のルートは URI (例: "file:///home/you/WORK")
   local root_uri = vim.b.fern.root.bufname
   local root = vim.uri_to_fname(root_uri) -- "file://..." → "/home/you/WORK"

   -- 行頭アイコンや余白をできるだけ除去して「表示名」を取る
   local line = vim.api.nvim_get_current_line()
   -- 先頭の空白/絵文字っぽい記号を削る（レンダラー差をざっくり吸収）
   local name = line
       :gsub("^%s+", "")
       :gsub("^[%z\1-\31%p%s]*", "") -- 記号や制御文字類をざっくり削る
       :gsub("%s+$", "")

   if name == "" then return nil end
   -- ルート + 表示名 で絶対パス化
   local path = root .. "/" .. name
   return vim.fn.fnamemodify(path, ":p")
end

vim.api.nvim_create_autocmd("FileType", {
   pattern = "fern",
   callback = function()
      -- <Leader>o: カーソル下が .html / .htm のときだけ既定アプリで開く
      vim.keymap.set("n", "<Leader>o", function()
         local name = vim.fn.expand("<cfile>"):lower()
         if name:match("%.html?$") then
            return "<Plug>(fern-action-open:system)"
         else
            vim.notify("HTMLファイルではありません")
            return ""
         end
      end, { buffer = true, expr = true, silent = true })
   end,
})

-- ロードの進行状況がわかるplugin
require("fidget").setup({})
