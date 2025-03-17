
-- packer.nvimの初期化
require("packer").startup(function(use)

   -- plugin 管理
   use "wbthomason/packer.nvim"

   -- BasicPlugin ----------------------------------
   use "easymotion/vim-easymotion"
   use "junegunn/vim-easy-align"
   use "lambdalisue/fern.vim"
   use "lambdalisue/vim-fern-git-status"
   use "simeji/winresizer"
   use "tpope/vim-commentary"
   use "tpope/vim-surround"
   use {
     'wfxr/minimap.vim',
     as = 'minimap',
   }

   -- 整形------------------------------------------
   use "mechatroner/rainbow_csv"
   use({
     'iamcco/markdown-preview.nvim',
     run = function() vim.fn['mkdp#util#install']() end
   })
   use "aklt/plantuml-syntax"
   use "weirongxu/plantuml-previewer.vim"
   use "folke/zen-mode.nvim"
   use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}
   use "norcalli/nvim-colorizer.lua"

   -- LSP関連プラグイン ---------------------------------------
   -- mason関係
   use 'williamboman/mason.nvim'
   use 'williamboman/mason-lspconfig.nvim'
   use "nvim-lua/plenary.nvim"
   -- lsp 
   use "neovim/nvim-lspconfig"

   -- Snipet
   use "L3MON4D3/LuaSnip"
   use "saadparwaiz1/cmp_luasnip"

   -- 補完関係
   use "hrsh7th/nvim-cmp" -- 補完エンジン
   use "hrsh7th/cmp-nvim-lsp" -- LSP補完の連携
   use "hrsh7th/cmp-buffer" -- LSP補完の連携
   use "hrsh7th/cmp-path" -- ファイルパス補完
   use "hrsh7th/cmp-cmdline"

   use {
     'nvim-telescope/telescope.nvim', tag = '0.1.8',
     requires = { {'nvim-lua/plenary.nvim'} }
   }
   -- C# 関係
   use "OmniSharp/omnisharp-roslyn"
   use "Hoffs/omnisharp-extended-lsp.nvim"
end)




