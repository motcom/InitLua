local lspconfig = require("lspconfig")

lspconfig.rust_analyzer.setup({
   on_attach = function(_, bufnr)
      local opts = { buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
   end,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    },
  },
})

-- TOML (taplo)
lspconfig.taplo.setup({})

local dap = require("dap")
local codelldb_path = vim.fn.stdpath("data") .. "\\mason\\packages\\codelldb\\extension\\adapter\\codelldb.exe"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = { "--port", "${port}" },
    detached = false,
  },
}

dap.configurations.rust = {
  {
    name = "Debug Rust executable",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to exe: ", vim.fn.getcwd() .. "\\target\\debug\\", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}
