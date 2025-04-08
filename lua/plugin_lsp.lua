local opts = { noremap = true, silent = true }
--  mason setting -------------------------------------

---@diagnostic disable-next-line:undefined-field
require("mason").setup({
   ui = {
      icons = {
         package_installed   = "",
         package_pending     = "",
         package_uninstalled = "",
      },
   }
}
)

-------------------------------------------------------
-- LSPの設定
local lspconfig = require("lspconfig")

local cmp = require("cmp")

require("CopilotChat").setup({
})

local capabilities = require 'cmp_nvim_lsp'.default_capabilities()
lspconfig.pyright.setup {
   on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
      vim.keymap.set("n", "gr", builtin.lsp_references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>d", builtin.lsp_type_definitions, opts)
   end,

   flags = {
      debounce_text_changes = 150, -- テキスト変更後の更新待機時間
   },
   settings = {
      python = {
         analysis = {
            typeCheckingMode = "basic",   -- 型チェックの厳密さ ("off", "basic", "strict")
            autoSearchPaths = true,       -- パスを自動検索
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
   on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
      vim.keymap.set("n", "gr", builtin.lsp_references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
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
         local copilot = require('copilot.suggestion')
         if require("cmp").visible() then
            require("cmp").confirm({ select = true })
         else
            fallback()
         end
      end,

      ["<C-b>"] = cmp.mapping.scroll_docs(-4),  -- ドキュメントを上にスクロール
      ["<C-f>"] = cmp.mapping.scroll_docs(4),   -- ドキュメントを下にスクロール
      ["<C-Space>"] = cmp.mapping.complete(),
      ['<C-n>'] = cmp.mapping.select_next_item(), -- 次の候補に移動
      ['<C-p>'] = cmp.mapping.select_prev_item(), -- 前の候補に移動
      ['<C-e>'] = cmp.mapping.abort(),
   },
   sources = cmp.config.sources({
      { name = "copilot" },
      { name = "nvim_lsp" }, -- LSPからの補完
      { name = "path" },   -- ファイルパス補完
   }),
})

-- 特定のファイルタイプでの設定（例: Python）
cmp.setup.filetype('python', {
   sources = cmp.config.sources({
      { name = 'nvim_lsp' }, -- LSP補完
   }, {
      { name = 'path' },   -- ファイルパス補完
   })
})

-- omnisharp  --------------------------------------------------------
local omnisharp_extended = require("omnisharp_extended")
local on_attach = function(_, bufnr)
   -- OmniSharp (Telescope版)
   vim.keymap.set("n", "gd", function()
      omnisharp_extended.telescope_lsp_definition({ jump_type = "vsplit" })
   end, opts)
   vim.keymap.set("n", "gi", omnisharp_extended.telescope_lsp_implementation, opts)
   vim.keymap.set("n", "gr", omnisharp_extended.telescope_lsp_references, opts)
   vim.keymap.set("n", "<leader>D", omnisharp_extended.telescope_lsp_type_definition, opts)
   vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
   vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
   vim.keymap.set('n', '<C-l>', vim.lsp.buf.code_action, { noremap = true, silent = true })
end

local pid = vim.fn.getpid()
local omnisharp_bin = vim.fn.stdpath("data") .. "/mason/bin/omnisharp.cmd"
require("lspconfig").omnisharp.setup({
   cmd = {
      omnisharp_bin,
      "--languageserver",
      "--hostPID",
      tostring(pid),
   },
   on_attach = on_attach,
   handlers = {
      ["textDocument/definition"] = omnisharp_extended.handler,
   },
   -- その他オプション（必要に応じて）
})

-- cmp_capabilities の例
require('lspconfig').clangd.setup({
   capabilities = capabilities,
   on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
      vim.keymap.set("n", "gr", builtin.lsp_references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
   end,

})

-- lemminx --------------------------------------------------------
require("lspconfig").lemminx.setup({
   filetypes = { "xml", "xaml" },
   extensions = { "xml", "xaml" },
   root_dir = require("lspconfig.util").root_pattern({ ".git", ".csproj", ".sln" }),
   capabilities = capabilities,
   on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
      vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
      vim.keymap.set("n", "gr", builtin.lsp_references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
   end,
})
