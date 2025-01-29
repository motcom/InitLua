
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
-- LSPの設定
local lspconfig = require("lspconfig")
require('lspconfig').pyright.setup{
  on_attach = function(client, bufnr)
    -- キーバインドや設定をLSPにアタッチしたときにカスタマイズ
    local opts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- 定義へジャンプ
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)       -- ホバー表示
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts) -- リファレンスジャンプ
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts) -- リネーム
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

-- rust tool rustanalyzer manager
local rt = require("rust-tools")
rt.setup({
  server = {
    on_attach = function(client, bufnr)
      local opts = { noremap=true, silent=true }
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
local luasnip = require("luasnip")
local cmp = require("cmp")

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

-- vim spector の設定 --------------------------------------------------------------------------
vim.g.vimspector_sidebar_width = 85
vim.g.vimspector_bottombar_height = 15
vim.g.vimspector_terminal_maxwidth = 70

vim.api.nvim_set_keymap("n", "<F5>", ":call vimspector#Launch()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F6>", ":call vimspector#Continue()<CR>", {noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F7>", ":call vimspector#Stop()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F8>", ":call vimspector#Reset()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<F9>", ":call vimspector#ToggleBreakpoint()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<F10>", ":call vimspector#StepOver()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F11>", ":call vimspector#StepInto()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F12>", ":call vimspector#StepOut()<CR>", { noremap = true, silent = true })


-- VimSpectorLanchFunction ---------------------------

vim.api.nvim_create_user_command("Debug", 
function()
    run_setting = require("run_setting")
    local root_dir     = find_project_root()
    local project_name = vim.fn.fnamemodify(root_dir,":t")
    local project_dir  = vim.fn.fnamemodify(root_dir,":h")
    local file_path  = project_dir .."/".. project_name .. "/" .. ".vimspector.json"
   local app = project_name .. ".exe"
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

    local file = io.open(file_path,"w")
    if file then
       file:write(result)
       file:close()
       print("File written to: " .. file_path)
    else
       print("Error: Could not write to file.")
    end
end,{})



