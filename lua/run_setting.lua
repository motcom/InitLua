

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
   elseif ext == "cs" then
      vim.cmd("w!")
      vim.cmd("!dotnet run")
   elseif ext == "c" then
      vim.cmd("w!")
      vim.cmd("!make run")
   end
end
vim.api.nvim_create_user_command("Run", run, {})
-------------------------------- Run Setting End ----------------------------------------


--------------------------------- Python Runm Setting Start-------------------------------------
-- プロジェクトのルートディレクトリを特定する関数
local function find_project_root()
    -- 探索対象のルート判定ファイル/ディレクトリ
    local markers = { ".git", "pyproject.toml", "setup.py", "main.py" }
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

local command = vim.fn.stdpath("data") .. "\\mason\\packages\\netcoredbg\\netcoredbg.exe"

--------------------------------- Python Runm Setting End-------------------------------------
