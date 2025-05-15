
-- Utility: Run setting for CMake, Python, and Lua projects in Neovim
local function getTargetExe()
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



--------------------------------- Python Runm Setting Start-------------------------------------
-- プロジェクトのルートディレクトリを特定する関数
local function find_project_root()
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

-- Pythonコマンドを設定
local python_command = "python"

-- 実行コマンドを定義する関数
local function create_run_command()
    local root_dir = find_project_root()
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
      local root = find_project_root()
      print(root .. "\\CMakeLists.txt")
      if vim.fn.filereadable(root .. "\\CMakeLists.txt") == 1 then
         print("cmkake run")
         vim.fn.system("cmake --build build --config DEBUG")
         local exe_file_name = getTargetExe()
         vim.cmd("!build\\".. exe_file_name)
      else
         local file = vim.fn.expand("%:t")
         local out = vim.fn.expand("%:r") .. ".exe"
         if ext == "c" then
            print("gcc run")
            vim.fn.system("gcc -g -o " .. out .. " " .. file)
            vim.cmd("!" .. out)
         elseif ext == "cpp" then
            print("g++ run")
            vim.fn.system("g++ -g -o " .. out .. " " .. file)
            vim.cmd("!" .. out)
         end
      end
   end
end
vim.api.nvim_create_user_command("Run", run, {})
-------------------------------- Run Setting End ----------------------------------------

