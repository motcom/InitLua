
local util = require("util") -- util.luaを読み込む
--------------------------------- Python Runm Setting Start-------------------------------------

-- Pythonコマンドを設定
local python_command = "python"

-- 実行コマンドを定義する関数
local function create_run_command()
    local root_dir = util.find_project_root()
    if root_dir then
        local project_name = vim.fn.fnamemodify(root_dir,":t")
        local project_dir  = vim.fn.fnamemodify(root_dir,":h")
        return string.format("cd %s && %s -m %s.main", project_dir, python_command, project_name )
    else
        error("Project root not found!")
    end
end

-- Neovimコマンドを定義
vim.api.nvim_create_user_command("Rum", function()
    local run_command = create_run_command()
    local result = vim.fn.system(run_command)
    print(run_command)
end, {})

function RunInTerminal(cmd)
    vim.cmd("split")
    vim.cmd("wincmd j")
    vim.cmd("terminal")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, true, true), "n", false)
    vim.schedule(function()
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\r")
  end)
end

--------------------------------- Python Runm Setting End-------------------------------------

-- Cのrunセッティングはcmakeで作り直さないで実行しているファイルが増えた場合はbuildするひつようがあるのでBuildを実行してからrunをする
-------------------------------- Run Setting Start ----------------------------------------

local function run()
   local ext = vim.fn.expand("%:e")
   if ext == "py" then
      vim.cmd("w!")
      if vim.fn.filereadable("main.py") == 1 then
         vim.cmd("!python main.py")
      else
         vim.cmd("!python %")
      end
   elseif ext == "lua" then
      vim.cmd("w!")
      vim.cmd("!lua %")
   elseif ext == "c" or ext=="cpp" then
      vim.cmd("w!")
      local root = util.find_project_root()
      print(root .. "\\CMakeLists.txt")
      if vim.fn.filereadable(root .. "\\CMakeLists.txt") == 1 then
         -- cmake がある場合
         print("cmake run")
         vim.fn.system("cmake --build build --config DEBUG")
         local exe_file_name = util.getTargetExe()
         RunInTerminal("build\\"..exe_file_name)
      else
         -- cmake がない場合
         local file = vim.fn.expand("%:t")
         local out = vim.fn.expand("%:r") .. ".exe"
         if ext == "c" then
            print("cl run:" .. out)
            vim.fn.system("cl -g -o " .. out .. " " .. file)
            RunInTerminal(out)
         elseif ext == "cpp" then
            print("cl run:" .. out)
            vim.fn.system("cl -g -o " .. out .. " " .. file)
            RunInTerminal(out)
         end
      end
   end
end
vim.api.nvim_create_user_command("Run", run, {})
-------------------------------- Run Setting End ----------------------------------------

