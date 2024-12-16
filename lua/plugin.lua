

-- packer.nvimの初期化
require("packer").startup(function(use)
   use "wbthomason/packer.nvim"
   use "neovim/nvim-lspconfig"
   -- LSP関連プラグイン
   use 'williamboman/mason.nvim'
   -- masonとlspconfigの連携
   use 'williamboman/mason-lspconfig.nvim' 
   use "nvim-lua/plenary.nvim"
   -- Rust開発向けツール
   use 'simrat39/rust-tools.nvim' -- Rust Analyzerの機能拡張

   use "L3MON4D3/LuaSnip"

   use "hrsh7th/nvim-cmp" -- 補完エンジン
   use "hrsh7th/cmp-nvim-lsp" -- LSP補完の連携
   use "hrsh7th/cmp-path" -- ファイルパス補完
   use {
       "zbirenbaum/copilot.lua",
       cmd = "Copilot",
       config = function()
         require("copilot").setup({
           suggestion = { enabled = false },
           panel = { enabled = false },
           copilot_node_command = 'node'
         })
       end,
    }
   use {
     "zbirenbaum/copilot-cmp",
     config = function ()
       require("copilot_cmp").setup()
     end
   }
  use {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  }
   use "easymotion/vim-easymotion"
   use "junegunn/vim-easy-align"
   use "lambdalisue/fern.vim"
   use "ellisonleao/gruvbox.nvim"
   use "simeji/winresizer"
   use "tpope/vim-commentary"
   use "tpope/vim-surround"
   use "mechatroner/rainbow_csv"
   use "weirongxu/plantuml-previewer.vim"
   use "norcalli/nvim-colorizer.lua"
   use "folke/zen-mode.nvim"
   use "tell-k/vim-autopep8"
   use {
     'wfxr/minimap.vim',
     as = 'minimap',
   }
   use {
     "windwp/nvim-autopairs",
     config = function()
       require("nvim-autopairs").setup {}
     end
   }
   use "puremourning/vimspector"
   use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}
end)


-- vim spector の設定 --------------------------------
vim.g.vimspector_sidebar_width = 85
vim.g.vimspector_bottombar_height = 15
vim.g.vimspector_terminal_maxwidth = 70

vim.api.nvim_set_keymap("n", "<F5>", ":call vimspector#Launch()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F6>", ":call vimspector#Reset()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<F7>", ":call vimspector#Continue()<CR>", {noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F8>", ":call vimspector#Stop()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<F9>", ":call vimspector#ToggleBreakpoint()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<F10>", ":call vimspector#StepOver()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F11>", ":call vimspector#StepInto()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F12>", ":call vimspector#StepOut()<CR>", { noremap = true, silent = true })



-- VimSpectorLanchFunction ---------------------------

vim.api.nvim_create_user_command("Reset", 
function()
   local app = vim.fn.expand("%:t:r")
   local result = 
[[
{
  "configurations": {
    "launch": {
      "adapter": "CodeLLDB",
      "filetypes": [ "rust" ],
      "configuration": {
        "request": "launch",
        "program": "${workspaceRoot}/target/debug/]]..app..[["
      }
    }
  }
}
]]

end, {range = true})


--  mason setting -------------------------------------
require("mason").setup({
   ui = {
      icons = {
         package_installed = "",
         package_pending = "",
         package_uninstalled = "",

      },
   }
}
)
require("mason-lspconfig").setup()
-------------------------------------------------------


require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt", "vim" },
  enable_check_bracket_line = true, -- 同じ行でのみ括弧を閉じる
})

-- minimap の設定
vim.g.minimap_width = 10

-- EasyMotionの<Leader><Leader>マッピングを無効化
vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_use_smartsign_us = 1

-- LSPの設定
local lspconfig = require("lspconfig")
lspconfig.pyright.setup{}

local rt = require("rust-tools")
rt.setup({
  server = {
    on_attach = function(client, bufnr)
      local opts = { noremap=true, silent=true }

      vim.api.nvim_buf_set_option(bufnr,"shiftwidth",3)
      vim.api.nvim_buf_set_option(bufnr,"tabstop",3)
      vim.api.nvim_buf_set_option(bufnr,"softtabstop",3)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    end,
  },
  tools = {
    executor = require("rust-tools.executors").termopen, -- Cargoコマンド実行
    reload_workspace_from_cargo_toml = true,
  },
  settings = {
    ["rust-analyzer"] = {
      rustfmt = {
         extraArgs = { "--congig","max_width=50"},
      },
      checkOnSave = {
        command = "clippy",
      },
      cargo = {
        allFeatures = true,
      },
      procMacro = {
        enable = true,
      },
    },
  },
  hover_actions = {
    auto_focus = false,
  },
})

-- Rustファイル保存時に自動でフォーマットする
vim.api.nvim_create_autocmd("BufWritePre",{
   pattern = "*.rs",
   callback = function()
      vim.cmd("!rustfmt")
   end,
})


-- nvim-cmpの設定 ----------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")

-- 下記cmp_setupで使用
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end


cmp.setup({

  window = {
    documentation = {
      max_height = 15,
      max_width = 60,
    },
  },
  snnipet = {
      expand = function(args)
         luasnip.lsp_expand(args.body)
      end,
   },
  mapping = {
   ["<C-y>"] = function(fallback)
      local entry = cmp.get_selected_entry() -- 現在選択されている補完エントリを取得
      if entry then
        local documentation = entry.documentation or '' -- ドキュメントを取得
        vim.fn.setreg('+', documentation) -- クリップボード("+レジスタ")に保存
        print("補完ヒントをクリップボードに保存しました!")
      else
        fallback() -- エントリがない場合は通常の挙動
      end
    end,
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enterで選択した補完を確定
    ['<C-n>'] = cmp.mapping.select_next_item(), -- 次の候補に移動
    ['<C-p>'] = cmp.mapping.select_prev_item(), -- 前の候補に移動
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.confirm({select = true})
      else
        fallback()
      end
    end),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSPからの補完
    { name = "path" },     -- ファイルパス補完
    { name = "copilot" },  -- Copilot補完
  }),
})

-- 特定のファイルタイプでの設定（例: Python）
cmp.setup.filetype('python', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- LSP補完
  }, {
    { name = 'path' },     -- ファイルパス補完
  })
})

-- 補完時のTabキーの挙動を変更
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end

-- CopilotChatの設定
require("CopilotChat").setup({
    show_help = "yes",
    prompts = {
        Explain = {
            prompt = "/COPILOT_EXPLAIN コードを日本語で説明してください",
            description = "コードの説明をお願いする",
        },
        Review = {
            prompt = '/COPILOT_REVIEW コードを日本語でレビューしてください。',
            description = "コードのレビューをお願いする",
        },
        Fix = {
            prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします。",
            description = "コードの修正をお願いする",
        },
        Optimize = {
            prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。説明は日本語でお願いします。",
            description = "コードの最適化をお願いする",
        },
        Docs = {
            prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントコメントを日本語で生成してください。",
            description = "コードのドキュメント作成をお願いする",
        },
        Tests = {
            prompt = "/COPILOT_TESTS 選択したコードの詳細なユニットテストを書いてください。説明は日本語でお願いします。",
            description = "テストコード作成をお願いする",
        },
        FixDiagnostic = {
            prompt = 'コードの診断結果に従って問題を修正してください。修正内容の説明は日本語でお願いします。',
            description = "コードの修正をお願いする",
            selection = require('CopilotChat.select').diagnostics,
        },
        Commit = {
            prompt =
            '実装差分に対するコミットメッセージを日本語で記述してください。',
            description = "コミットメッセージの作成をお願いする",
            selection = require('CopilotChat.select').gitdiff,
        },
        CommitStaged = {
            prompt =
            'ステージ済みの変更に対するコミットメッセージを日本語で記述してください。',
            description = "ステージ済みのコミットメッセージの作成をお願いする",
            selection = function(source)
                return require('CopilotChat.select').gitdiff(source, true)
            end,
        },

     },
})

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

-- CopilotChat のコマンドを追加
vim.api.nvim_create_user_command("Reset", 
function()
   vim.cmd("CopilotChatReset")
end, {range = true})

vim.api.nvim_create_user_command("Fix", 
function()
   vim.cmd("CopilotChatFix")
end, {range = true})

vim.api.nvim_create_user_command("Unit",
function()
   vim.cmd("CopilotChatTests")
end, {range = true})

vim.api.nvim_create_user_command("Commit",
function()
   vim.cmd("CopilotChatCommit")
end, {range = true})

vim.api.nvim_create_user_command("Refactor",
function()
   vim.cmd("CopilotChatOptimize")
end, {range = true})

vim.api.nvim_create_user_command("Ex",
function()
   vim.cmd("CopilotChatExplain")
end, {range = true})

vim.api.nvim_create_user_command("Chat",
function()
   vim.cmd("CopilotChat")
end, {range = true})

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
   ensure_installed = {"lua","python","toml","json","rust"},
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
}

