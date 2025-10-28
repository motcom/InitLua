-- mason は今のままでOK -------------------------------------------------------
require("mason").setup({
   install_root_dir = vim.fn.stdpath("data") .. "/mason",
   PATH = "prepend",
   log_level = vim.log.levels.INFO,
   max_concurrent_installers = 4,
   registries = { "github:mason-org/mason-registry" },
   providers = { "mason.providers.client", "mason.providers.registry-api" },
   github = {},
   pip = {},
   ui = { icons = { package_installed = "○", package_pending = "p", package_uninstalled = "x" } },
})

-- ★ ここから lspconfig は使わない ------------------------------------------
local cmp = require("cmp")
require("CopilotChat").setup({})

-- 共通 capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
pcall(function()
   capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
end)

-- 共通 on_attach（あなたのキーマップをそのまま移植）
local function on_attach(_, bufnr)
   local builtin = require("telescope.builtin")
   local optf = { noremap = true, silent = true, buffer = bufnr }
   vim.keymap.set("n", "gd", builtin.lsp_definitions, optf)
   vim.keymap.set("n", "gi", builtin.lsp_implementations, optf)
   vim.keymap.set("n", "gr", builtin.lsp_references, optf)
   vim.keymap.set("n", "K", vim.lsp.buf.hover, optf)
   vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, optf)
   vim.keymap.set("n", "<leader>d", builtin.lsp_type_definitions, optf)
   vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true })
   -- 次/前の診断へ（レベル不問）
   vim.keymap.set("n", "<A-n>", function()
      vim.diagnostic.jump({ count = 1, float = true })
   end, optf)

   vim.keymap.set("n", "<A-p>", function()
      vim.diagnostic.jump({ count = -1, float = true })
   end, optf)
end

-- -------------------------
-- 各 LSP サーバの登録だけ
-- -------------------------

-- Pyright
vim.lsp.config('pyright', {
   capabilities = capabilities,
   on_attach = on_attach,
   flags = { debounce_text_changes = 150 },
   settings = {
      python = {
         analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
         },
      },
   },
})

-- JSON (schemastore 使用)
vim.lsp.config('jsonls', {
   capabilities = capabilities,
   on_attach = on_attach,
   settings = {
      json = {
         schemas = require("schemastore").json.schemas(),
         validate = { enable = true },
         format = { enable = true },
      },
   },
})

-- Lua
vim.lsp.config('lua_ls', {
   capabilities = capabilities,
   on_attach = on_attach,
   settings = {
      Lua = {
         runtime = { version = 'LuaJIT' },
         diagnostics = { globals = { 'vim' } },
         workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
         telemetry = { enable = false },
      },
   },
})

-- Ruff (フォーマッタ用途の能力だけ残す)
vim.lsp.config('ruff', {
   on_attach = function(client, bufnr)
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
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = false
   end,
})

-- Rust
vim.lsp.config('rust_analyzer', {
   capabilities = capabilities,
   on_attach = on_attach,
   settings = {
      ["rust-analyzer"] = {
         cargo = { allFeatures = true },
         checkOnSave = true,
         check = { command = "clippy" },
         completion = { autoimport = { enable = true } },
         imports = { granularity = { group = "module" }, prefix = "self" },
         procMacro = { enable = true },
      },
   },
})

-- -------------------------
-- 実際に起動（enable）
-- -------------------------
vim.lsp.enable({ 'pyright', 'jsonls', 'lua_ls', 'ruff', 'rust_analyzer' })

-- nvim-cmp 設定（あなたのまま）
local luasnip = require("luasnip")
cmp.setup({
   window = { documentation = cmp.config.window.bordered() },
   snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
   mapping = {
      ['<Tab>'] = function(fallback)
         if require("cmp").visible() then require("cmp").confirm({ select = true }) else fallback() end
      end,
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-e>'] = cmp.mapping.abort(),
   },
   sources = cmp.config.sources({
      { name = "copilot" },
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "buffer",                 keyword_length = 2 },
      { name = "luasnip" },
      { name = "path" },
   }),
})

cmp.setup.filetype('python', {
   sources = cmp.config.sources({ { name = 'nvim_lsp' } }, { { name = 'path' } })
})
