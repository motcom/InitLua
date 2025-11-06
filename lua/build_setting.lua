


local function build_rust()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if not file:match("%.rs$") then
    print("Not a Rust file.")
    return
  end
  local proj_dir = require("run_setting").find_cargo_dir(file)
  if not proj_dir then
    print("No Cargo.toml found.")
    return
  end
   local total_str = "cd " .. proj_dir .. " && cargo build"
   require("util").RunInTerminal(total_str)
end

vim.api.nvim_create_user_command("B", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file:match("%.rs$") then
    build_rust()
  end
end, {})
