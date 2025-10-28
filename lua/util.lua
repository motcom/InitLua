local M = {}

-- プロジェクトのルートディレクトリを特定する関数
function M.find_project_root()
    -- 探索対象のルート判定ファイル/ディレクトリ
    local markers = {"cmakelists.txt","main.c", ".git", "pyproject.toml", "setup.py", "main.py","Cargo.toml" ,"main.rs"}
      
   
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
   local lines ={}
   for line in io.lines(cmake_path) do -- Check if CMakeLists.txt exists
      table.insert(lines, line) -- 各行をテーブルに格納
   end
   
   -- maya projectの場合falseを返す
   for _,line in ipairs(lines) do
      line = line:lower() -- 小文字に変換して比較
      if line:find("maya") then
         return false
      end
   end

   for _,line in ipairs(lines) do
      if line:find("Qt5") or line:find("Qt6") then
         print("Qt is used in this project.")
         return true
      end
   end
   return false
end

function M.isOpen3DProject()
   local util = require("util")
   local root_path = util.find_project_root()
   local cmake_path = root_path .. "/CMakeLists.txt"
   local lines ={}
   for line in io.lines(cmake_path) do -- Check if CMakeLists.txt exists
      table.insert(lines, line) -- 各行をテーブルに格納
   end

   for _,line in ipairs(lines) do
      if line:find("Open3D") then
         print("Open3D is used in this project.")
         return true
      end
   end
   return false
end

function M.RunInTerminalTabNew(cmd)
    vim.cmd("tabnew")
    vim.cmd("terminal")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, true, true), "n", false)
    vim.schedule(function()
        vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\r")
    end)
end

function M.RunInTerminal(cmd)
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("terminal")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, true, true), "n", false)
    vim.schedule(function()
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\r")
  end)
end

function M.isAvrProject()
   print("isAvrProject called")
   local util = require("util")
   local root_path = util.find_project_root()
   local toolchain_path = root_path .. "/toolchain-avr.cmake"
   print("toolchain_path:" .. toolchain_path)
   -- toolchain-avr.cmakeが存在するかチェック
   local toolchain_exists = vim.fn.filereadable(toolchain_path) == 1
   if toolchain_exists then
      print("toolchain-avr.cmake exists in this project.")
      return true
   end
   return false
end

function M.getTargetHexFile()
   local util = require("util")
   local root_path = util.find_project_root()
   local build_dir = root_path .. "/build/"
   local hex_files = vim.fn.glob(build_dir .. "*.hex", false, true)
   if #hex_files > 0 then
      return hex_files[1]
   else
      print("Error: No hex file found in " .. build_dir)
      return nil
   end
end

function M.isArduinoProject()
   local util = require("util")
   local root_path = util.find_project_root()
   local main_file_path = root_path .. "/main.cpp"
   local lines = io.lines(main_file_path) -- Check if main.cpp exists
   for line in lines do
      if line:find("Arduino.h") then
         print("Arduino is used in this project.")
         return true
      end
   end
   return false
end

return M
