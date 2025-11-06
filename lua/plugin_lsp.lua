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
local cmp = require("cmp")

require("CopilotChat").setup({
})


local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config("pyright", {
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
})

-- json setting
vim.lsp.config('jsonls', {
   capabilities = capabilities,
   settings = {
      json = {
         schemas = require("schemastore").json.schemas(),
         validate = { enable = true },
         format = { enable = true },
      },
   },
})

vim.lsp.config("lua_ls", {
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
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, optf)
   end,
})


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
         if require("cmp").visible() then require("cmp").confirm({ select = true }) else fallback() end
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
      { name = "nvim_lsp" },                                   -- LSPからの補完
      { name = 'nvim_lsp_signature_help' },                    -- LSPのシグネチャヘルプ
      { name = 'buffer',                 keyword_length = 2 }, -- source current buffer
      { name = "luasnip" },                                    -- LuaSnipからの補完
      { name = "path" },                                       -- ファイルパス補完
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
vim.lsp.config('ruff', {
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


vim.lsp.config("rust_analyzer", {
   capabilities = capabilities, -- ★ これを追加
   settings = {
      ["rust-analyzer"] = {
         cargo = { allFeatures = true },
         checkOnSave = true,
         completion = { autoimport = { enable = true } }, -- import 付き補完を許可
         imports = { granularity = { group = "module" }, prefix = "self" },
         procMacro = { enable = true },                   -- マクロ多用プロジェクトなら必須
      },
   },
   on_attach = function(_, bufnr)
      local optf = { noremap = true, silent = true, buffer = bufnr }
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "gd", builtin.lsp_definitions, optf)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, optf)
      vim.keymap.set("n", "gr", builtin.lsp_references, optf)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, optf)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, optf)
      vim.keymap.set("n", "<C-a>", vim.lsp.buf.code_action, optf)
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, optf)
   end,
})

-- ---- Slint filetype （vim-slint を使わない場合の保険） ----
vim.api.nvim_create_augroup("slint_ft", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "slint_ft",
  pattern = "*.slint",
  callback = function()
    vim.bo.filetype = "slint"
  end,
})

-- ---- Slint LSP -------------------------------------------------
vim.lsp.config("slint_lsp", {
  cmd = { "slint-lsp" },                 -- cargo install slint-lsp
  filetypes = { "slint" },
  -- 簡易ルート検出（必要なら root_dir を使う方法に差し替え可）
  root_markers = { ".git", "slint.toml" },
  -- もう少し厳密にやりたい場合はこちらを使う:
  -- root_dir = function(fname)
  --   local root = vim.fs.find({ "slint.toml", ".git" }, { upward = true, path = fname })[1]
  --   return root and vim.fs.dirname(root) or vim.loop.cwd()
  -- end,

  -- Slint LSP 固有の設定があればここに
  settings = {},
  on_attach = function(_, bufnr)
    -- 既存サーバと合わせたキーマップ（Telescope を使用）
    local optf = { noremap = true, silent = true, buffer = bufnr }
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "gd", builtin.lsp_definitions, optf)
    vim.keymap.set("n", "gi", builtin.lsp_implementations, optf)
    vim.keymap.set("n", "gr", builtin.lsp_references, optf)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, optf)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, optf)
    vim.keymap.set("n", "<leader>d", builtin.lsp_type_definitions, optf)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true, buffer = bufnr })
  end,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- 既存の enable リストに 'slint_lsp' を足す
vim.lsp.enable({ 'pyright', 'jsonls', 'lua_ls', 'ruff', 'rust_analyzer', 'slint_lsp' })
vim.lsp.enable({ 'pyright', 'jsonls', 'lua_ls', 'ruff', 'rust_analyzer' })
