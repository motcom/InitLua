local M = {}

local function find_cargo_dir(filepath)
  local uv = vim.loop
  local dir = uv.fs_realpath(vim.fn.fnamemodify(filepath, ":p:h"))
  while dir do
    for _, name in ipairs(vim.fn.readdir(dir)) do
      if name == "Cargo.toml" then
        return dir
      end
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end
  return nil
end


function M.run_python()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if not file:match("%.py$") then
    print("Not a Python file.")
    return
  end
  vim.cmd("split | terminal python " .. file)
end


function M.run_rust()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if not file:match("%.rs$") then
    print("Not a Rust file.")
    return
  end
  local proj_dir = find_cargo_dir(file)
  if not proj_dir then
    print("No Cargo.toml found.")
    return
  end
   local total_str = "cd " .. proj_dir .. " && cargo run"
   require("util").RunInTerminal(total_str)
end


vim.api.nvim_create_user_command("R", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file:match("%.rs$") then
    require("run_setting").run_rust()
  elseif file:match("%.py$") then
    require("run_setting").run_python()
  else
    print("Not a Rust or Python file.")
  end
end, {})
return M
