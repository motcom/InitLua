local M = {}


-- filepath を含むプロジェクトで最寄りの Cargo.toml のあるディレクトリを返す
 function M.find_cargo_dir(filepath)
  local abs = vim.fn.fnamemodify(filepath, ":p")          -- 絶対パス
  local start = vim.fs.dirname(abs)                       -- 開始ディレクトリ
  local hit = vim.fs.find("Cargo.toml", { path = start, upward = true })[1]
  return hit and vim.fs.dirname(hit) or nil
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
  if not (file:match("%.rs$") or file:match("%.slint")) then
    print("Not a Rust file.")
    return
  end
  local proj_dir = require("run_setting").find_cargo_dir(file)
  if not proj_dir then
    print("No Cargo.toml found.")
    return
  end
   local total_str = "cd " .. proj_dir .. " && cargo run"
   require("util").RunInTerminal(total_str)
end


vim.api.nvim_create_user_command("R", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file:match("%.rs$") or file:match("%.slint$") then
    require("run_setting").run_rust()
  elseif file:match("%.py$") then
    require("run_setting").run_python()
  else
    print("Not a Rust or Python file.")
  end
end, {})
return M
