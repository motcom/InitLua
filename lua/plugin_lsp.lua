
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
require("mason-lspconfig").setup()
-------------------------------------------------------
-- LSPの設定
local lspconfig = require("lspconfig")
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

lspconfig.html.setup {
  capabilities = capabilities,
  filetypes = { "html", "htmldjango" },
  on_attach = function(client,bufnr)
    client.server_capabilities.documentFormattingProvider = true
    
  end,
  settings = {
    html = {
      format = {
        enable = true
      },
      hover = {
        documentation = true,
        references = true
      }
    }
  }
}




-- CSS LSP 設定
lspconfig.cssls.setup {
  capabilities = capabilities,
  filetypes = { "css", "scss", "less" },
}

-- JavaScript (tsserver) LSP 設定
lspconfig.ts_ls.setup {
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  cmd = { "typescript-language-server", "--stdio" },

}

-- rust tool rustanalyzer manager
local rt = require("rust-tools")
rt.setup({
  server = {
    on_attach = function(client, bufnr)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- 定義へジャンプ
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)       -- ホバー表示
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts) -- リファレンスジャンプ
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts) -- リネーム

      vim.api.nvim_buf_set_option(bufnr,"shiftwidth",3)
      vim.api.nvim_buf_set_option(bufnr,"tabstop",3)
      vim.api.nvim_buf_set_option(bufnr,"softtabstop",3)
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


-- nvim-cmpの設定 ----------------------------------------
local cmp = require("cmp")
local luasnip = require("LuaSnip")
cmp.setup({
  window = {
    documentation = {
      max_height = 15,
      max_width = 60,
    },
  },
  snippet = {
      expand = function(args)
         luasnip.lsp_expand(args.body)
      end,
   },
  mapping = {
    ['<C-y>'] = cmp.mapping(function(fallback)
      -- <C-y>でドキュメントをクリップボードにコピー
      local entry = cmp.get_selected_entry()
      if entry then
        local completion_item = entry:get_completion_item()
        local documentation = completion_item.documentation.value
        -- 空でない場合のみコピー
        if text_to_copy ~= "" then
          vim.fn.setreg('+', documentation) -- クリップボードにコピー
        else
          print("No documentation or detail available")
        end
      else
        print("No entry selected")
        fallback()
      end
    end, { 'i', 'c' }), -- インサートモードとコマンドラインモードで有効

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

