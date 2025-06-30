-- packer.nvimの初期化
require("packer").startup(function(use)
   -- plugin 管理
   use "wbthomason/packer.nvim"
   use "EdenEast/nightfox.nvim"
   -- BasicPlugin ----------------------------------
   use "windwp/nvim-autopairs"
   use "easymotion/vim-easymotion"
   use "junegunn/vim-easy-align"
   use "lambdalisue/fern.vim"
   use "lambdalisue/vim-fern-git-status"
   use "simeji/winresizer"
   use "tpope/vim-commentary"
   use "tpope/vim-surround"
   -- 整形------------------------------------------
   use "mechatroner/rainbow_csv"
   use({
      'iamcco/markdown-preview.nvim',
      run = function() vim.fn['mkdp#util#install']() end
   })
   use "folke/zen-mode.nvim"
   use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
   use "norcalli/nvim-colorizer.lua"
   use "windwp/nvim-autopairs"
   -- LSP関連プラグイン ---------------------------------------
   -- mason関係
   use 'williamboman/mason.nvim'
   use 'williamboman/mason-lspconfig.nvim'
   use "nvim-lua/plenary.nvim"
   -- lsp
   use "neovim/nvim-lspconfig"

   -- dap
   use { "jay-babu/mason-nvim-dap.nvim", requires = "williamboman/mason.nvim" }
   use { "mfussenegger/nvim-dap" }
   use { "rcarriga/nvim-dap-ui", config = function() require("dapui").setup() end }
   use "nvim-neotest/nvim-nio"
   -- Snipet
   use "L3MON4D3/LuaSnip"
   use "saadparwaiz1/cmp_luasnip"

   -- 補完関係
   use "hrsh7th/nvim-cmp"     -- 補完エンジン
   use "hrsh7th/cmp-nvim-lsp" -- LSP補完の連携
   use "hrsh7th/cmp-buffer"   -- LSP補完の連携
   use "hrsh7th/cmp-path"     -- ファイルパス補完
   use "hrsh7th/cmp-cmdline"
   -- json
   use "b0o/schemastore.nvim"

   -- copilot
   use "github/copilot.vim"
   use({
      "zbirenbaum/copilot-cmp",
      after = { "copilot.lua" },
      config = function()
         require("copilot_cmp").setup()
      end,
   })


   use { "CopilotC-Nvim/CopilotChat.nvim",
      requires = {
         { "zbirenbaum/copilot.lua" },
         { "nvim-lua/plenary.nvim", branch = "master" }
      }
   }
   -- 検索
   use {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      requires = { { 'nvim-lua/plenary.nvim' } }
   }
   -- uml
   use "aklt/plantuml-syntax"
   use "weirongxu/plantuml-previewer.vim"
   use "tyru/open-browser.vim"

   -- indent-blankline
   use {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
         require("ibl").setup {
            indent = { char = "│" },
            scope = { enabled = true },
         }
      end
   }

   use({
      "danymat/neogen",
      requires = "nvim-treesitter/nvim-treesitter",
      config = function()
         require("neogen").setup({
            enabled = true,
            languages = {
               c = { template = { annotation_convention = "doxygen" } },
               cpp = { template = { annotation_convention = "doxygen" } },
            },
         })
      end,
   })
end)
