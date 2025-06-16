local M = {}

-- プロジェクトのルートディレクトリを特定する関数
function M.find_project_root()
    -- 探索対象のルート判定ファイル/ディレクトリ
    local markers = {"cmakelists.txt","main.c", ".git", "pyproject.toml", "setup.py", "main.py" }
    -- カレントディレクトリから上に探索
    local dir = vim.fn.getcwd()

    local dir_tmp = vim.fn.fnamemodify(dir, ":p") -- 正規化されたパス
    local drive = string.sub(dir_tmp, 1, 3) -- ドライブ部分を取得 (例: "C:\")
     print(drive)

    while dir ~= drive do
        for _, marker in ipairs(markers) do
            if vim.fn.glob(dir .. "/" .. marker) ~= "" then
                return dir
            end
        end
        -- 一段上に移動
        dir = vim.fn.fnamemodify(dir, ":h")
        print(dir)
    end
    return nil -- 見つからない場合
end

-- Utility: Run setting for CMake, Python, and Lua projects in Neovim
function M.getTargetExe()
   local target_name = nil
   for l in io.lines("CMakeLists.txt") do
     local name = l:match("^%s*add_executable%s*%(%s*([%w_]+)")
      if name then
         target_name = name
         break
      end
   end
   return target_name .. ".exe"
end

function M.isQtProject()

   local util = require("util")
   local root_path = util.find_project_root()
   local cmake_path = root_path .. "/CMakeLists.txt"
   local lines = io.lines(cmake_path) -- Check if CMakeLists.txt exists
   -- maya projectの場合falseを返す
   for line in lines do
      line = line:lower() -- 小文字に変換して比較
      if line:find("maya") then
         return false
      end
   end

   for line in lines do
      if line:find("Qt5") or line:find("Qt6") then
         print("Qt is used in this project.")
         return true
      end
   end
   return false
end

function M.RunInTerminal(cmd)
    vim.cmd("split")
    vim.cmd("wincmd j")
    vim.cmd("terminal")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, true, true), "n", false)
    vim.schedule(function()
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\r")
  end)
end

return M
