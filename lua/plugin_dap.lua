
------------------------------------------------------------
-- Common Variables
local dot_net_ver = "9.0"  -- .NETのバージョンを指定  

------------------------------------------------------------


require("mason-nvim-dap").setup({
  ensure_installed = { "coreclr" },  -- netcoredbg を使うために coreclr を指定
  automatic_installation = true,
})

local dap = require("dap")
local dapui = require("dapui")
dapui.setup()

dap.adapters.coreclr = {
  type = 'executable',
  command = vim.fn.stdpath("data") .. '\\mason\\packages\\netcoredbg\\netcoredbg\\netcoredbg.exe',
  args = { '--interpreter=vscode' },
}

-- dir がルートかどうかをチェック（Windows でも対応）
local Path = require("plenary.path")
local function is_root(dir)
  local parent = dir:parent()
  return parent:absolute() == dir:absolute()
end



local function find_csproj_root()
  local dir = Path:new(vim.fn.expand("%:p:h"))
  while dir and not is_root(dir) do
    local csproj_files = vim.fn.glob(dir:absolute() .. "/*.csproj", false, true)
    if #csproj_files > 0 then
      local csproj_path = Path:new(csproj_files[1])
      local abs_path = csproj_path:parent():absolute()
      local dll_name = csproj_path:make_relative(abs_path):gsub("%.csproj$", ".dll")
      return abs_path, dll_name
    end
    dir = dir:parent()
  end
  error("No .csproj file found in parent directories")
end

local dap_config_setting = function()
   local proj_path, dll_name = find_csproj_root()
   dap.configurations.cs = {
     {
       type = "coreclr",
       name = "Launch - netcoredbg",
       request = "launch",
       program = function()
         return proj_path .. '\\bin\\Debug\\net' .. dot_net_ver .. '\\' .. dll_name
       end,
     },
   }
   dap.continue()
end


-- セッションに応じてUIを自動で開閉
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- キーマップ（ここでも良いし、別ファイルでもOK）
vim.keymap.set('n', '<S-F5>', function() dapui.toggle() end)
vim.keymap.set('n', '<F5>',dap_config_setting )
vim.keymap.set('n', '<F9>', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)


