
local opts = { noremap=true, silent=true }
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

local capabilities = require'cmp_nvim_lsp'.default_capabilities()
lspconfig.pyright.setup{
  on_attach = function(client, bufnr)
    -- キーバインドや設定をLSPにアタッチしたときにカスタマイズ
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- 定義へジャンプ
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)       -- ホバー表示
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts) -- リファレンスジャンプ
    vim.keymap.set('n', 'gn', vim.lsp.buf.rename, opts) -- リネーム
  end,
  flags = {
    debounce_text_changes = 150, -- テキスト変更後の更新待機時間
  },
  settings = {
    python = {
      analysis = {
              typeCheckingMode = "basic", -- 型チェックの厳密さ ("off", "basic", "strict")
               autoSearchPaths = true,     -- パスを自動検索
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
            format = {enable = true},
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
}


-- rust tool rustanalyzer manager
-- nvim-cmpの設定 ----------------------------------------
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
    ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- ドキュメントを上にスクロール
    ["<C-f>"] = cmp.mapping.scroll_docs(4), -- ドキュメントを下にスクロール
    ["<C-Space>"] = cmp.mapping.complete(),
    ['<C-n>'] = cmp.mapping.select_next_item(), -- 次の候補に移動
    ['<C-p>'] = cmp.mapping.select_prev_item(), -- 前の候補に移動
    ['<C-e>'] = cmp.mapping.abort(),
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
     if cmp.visible() then
         cmp.confirm({select = true})
      else
         fallback()
      end
    end),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSPからの補完
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

  -- Hover（通常 LSP 関数）
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  -- Rename（Telescope内でなく、UIがある場合 telescope.nvimの拡張なし）
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

  -- Code Action（Telescopeを使う場合はこちら）
  vim.keymap.set("n", "<leader>ca", require("telescope.builtin").lsp_code_actions, opts)

  -- Signature Help（関数引数の表示など）
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
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
