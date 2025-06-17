local opts = { noremap = true, silent = true }

--  mason setting -------------------------------------

require("mason").setup({
   install_root_dir = vim.fn.stdpath("data") .. "/mason",
   PATH = "prepend",
   log_level = vim.log.levels.INFO,
   max_concurrent_installers = 4,
   registries = { "github:mason-org/mason-registry" },
   providers = {
      "mason.providers.client",
      "mason.providers.registry-api"
   },
   github = {}, -- ← ダミーで追加
   pip = {},    -- ← ダミーで追加
   ui = {
      icons = {
         package_installed = "○",
         package_pending = "p",
         package_uninstalled = "x"
      }
   }
})

-------------------------------------------------------
-- LSPの設定
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local cmp = require("cmp")

require("CopilotChat").setup({
})

local capabilities = require 'cmp_nvim_lsp'.default_capabilities()
lspconfig.pyright.setup {
   on_attach = function(_, bufnr)
      local optf = { noremap = true, silent = true, buffer = bufnr }
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "gd", builtin.lsp_definitions, optf)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, optf)
      vim.keymap.set("n", "gr", builtin.lsp_references, optf)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, optf)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, optf)
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>d", builtin.lsp_type_definitions, optf)
   end,

   flags = {
      debounce_text_changes = 150, -- テキスト変更後の更新待機時間
   },
   settings = {
      python = {
         analysis = {
            typeCheckingMode = "basic",    -- 型チェックの厳密さ ("off", "basic", "strict")
            autoSearchPaths = true,        -- パスを自動検索
            useLibraryCodeForTypes = true, -- ライブラリコードの型情報を使用
         },
      },
   },
}

-- json setting
require("lspconfig").jsonls.setup({
   capabilities = capabilities,
   settings = {
      json = {
         schemas = require("schemastore").json.schemas(),
         validate = { enable = true },
         format = { enable = true },
      },
   },
})

lspconfig.lua_ls.setup {
   settings = {
      Lua = {
         runtime = { version = 'LuaJIT' },
         diagnostics = { globals = { 'vim' } },
         workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
         },
         telemetry = { enable = false },
      },
   },
   capabilities = capabilities,
   on_attach = function(_, bufnr)
      local optf = { noremap = true, silent = true, buffer = bufnr }
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "gd", builtin.lsp_definitions, optf)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, optf)
      vim.keymap.set("n", "gr", builtin.lsp_references, optf)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, optf)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, optf)
   end,
}


local luasnip = require("luasnip")
cmp.setup({
   window = {
      documentation = cmp.config.window.bordered()
   },
   snippet = {
      expand = function(args)
         luasnip.lsp_expand(args.body)
      end,
   },
   mapping = {
      ['<Tab>'] = function(fallback)
         if require("cmp").visible() then
            require("cmp").confirm({ select = true })
         else
            fallback()
         end
      end,

      ["<C-b>"] = cmp.mapping.scroll_docs(-4),    -- ドキュメントを上にスクロール
      ["<C-f>"] = cmp.mapping.scroll_docs(4),     -- ドキュメントを下にスクロール
      ["<C-Space>"] = cmp.mapping.complete(),
      ['<C-n>'] = cmp.mapping.select_next_item(), -- 次の候補に移動
      ['<C-p>'] = cmp.mapping.select_prev_item(), -- 前の候補に移動
      ['<C-e>'] = cmp.mapping.abort(),
   },
   sources = cmp.config.sources({
      { name = "copilot" },
      { name = "nvim_lsp" }, -- LSPからの補完
      { name = 'nvim_lsp_signature_help'}, -- LSPのシグネチャヘルプ
      { name = 'buffer', keyword_length = 2 },        -- source current buffer
      { name = "luasnip" },   -- LuaSnipからの補完
      { name = "path" },     -- ファイルパス補完
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

-- python formatter
require("lspconfig").ruff.setup({
   on_attach = function(client, bufnr)
      -- 必要なら設定（例：hover無効）
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.completionProvider = nil
      client.server_capabilities.definitionProvider = false
      client.server_capabilities.referencesProvider = false
      client.server_capabilities.signatureHelpProvider = nil
      client.server_capabilities.documentSymbolProvider = false
      client.server_capabilities.workspaceSymbolProvider = false
      client.server_capabilities.codeActionProvider = false
      client.server_capabilities.renameProvider = false
      client.server_capabilities.documentHighlightProvider = false
      client.server_capabilities.semanticTokensProvider = nil
      client.server_capabilities.documentFormattingProvider = true -- ← ここだけ残す
      client.server_capabilities.documentRangeFormattingProvider = false
   end,
})


require('lspconfig').clangd.setup({
   capabilities = capabilities,
   cmd = { "clangd", "--compile-commands-dir=.", "--fallback-style=none","--header-insertion=never","--cross-file-rename"},
   filetype = { "c", "cpp" },
   on_attach = function(_, bufnr)
      local builtin = require("telescope.builtin")
      local optf = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set("n", "gd", builtin.lsp_definitions, optf)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, optf)
      vim.keymap.set("n", "gr", builtin.lsp_references, optf)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, optf)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, optf)
   end,
   root_dir = util.root_pattern(
      ".git", "CMakeLists.txt"
   ),
})

require('lspconfig').cmake.setup({
   capabilities = require('cmp_nvim_lsp').default_capabilities(),
   on_attach = function(_, bufnr)
      local opf = { noremap = true, silent = true, buffer = bufnr }
      local map = vim.keymap.set
      map("n", "K", vim.lsp.buf.hover, opf)
      map("n", "gd", vim.lsp.buf.definition, opf)
      map("n", "<leader>rn", vim.lsp.buf.rename, opf)
      map("n", "gr", vim.lsp.buf.references, opf)
   end,
   cmd = { "cmake-language-server" },
   filetypes = { "cmake" },
   init_options = {
      buildDirectory = "build",
   },
   root_dir = require('lspconfig.util').root_pattern("CMakePresets.json", "CTestConfig.cmake", ".git", "build",
      "CMakeLists.txt"),
})
