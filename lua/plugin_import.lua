
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
   -- markdown preview
   use({
     'iamcco/markdown-preview.nvim',
     run = function() vim.fn['mkdp#util#install']() end
   })
   use "aklt/plantuml-syntax"
   use "weirongxu/plantuml-previewer.vim"
   
   -- markdown preview 

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
   -- use "puremourning/vimspector"
   use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}

end)
