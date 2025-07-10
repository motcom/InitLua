
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
-- AVR用---------------------------------------------------------------------------------------- 
-- get_avr_mcu
local function get_mcu_from_toolchain(tool_chain_file_path)
    local mcu = nil
    for line in io.lines(tool_chain_file_path) do
        local cflags = line:match('set%(%s*CMAKE_C_FLAGS%s+"%-mmcu=(.-)"%s*%)')
        if cflags then
            mcu = cflags
            break
        end
    end
    return mcu
end

-- マッピングテーブル
local mcu_map = {
    atmega328p = "m328p",
    atmega8    = "m8",
    attiny2313 = "t2313",
    attiny13   = "t13",
    attiny13a  = "t13",   -- A付きでも略称は同じ
    attiny85   = "t85",
}

-- 変換関数
local function shorten_mcu(name)
    return mcu_map[name]
end

--------------------------------- Python Runm Setting End-------------------------------------

-- Cのrunセッティングはcmakeで作り直さないで実行しているファイルが増えた場合はbuildするひつようがあるのでBuildを実行してからrunをする
-------------------------------- Run Setting Start ----------------------------------------

local function run(opts)
   local args = opts.args or ""
   
   local ext = vim.fn.expand("%:e")
   if ext == "py" then
      vim.cmd("w!")
      if vim.fn.filereadable("main.py") == 1 then
         local build_strs = "python main.py ".. args
         util.RunInTerminal(build_strs)
      else
         local filename = vim.api.nvim_buf_get_name(0)
         local build_strs = "python " .. filename .. " " .. args
         util.RunInTerminal(build_strs)
      end
   elseif ext == "lua" then
      vim.cmd("w!")
      local filename = vim.api.nvim_buf_get_name(0)
      local build_strs = "lua " .. filename .." " .. args
      util.RunInTerminal(build_strs)

   elseif ext == "c" or ext == "cpp" or ext=="h" then
      vim.cmd("w!")
      local root = util.find_project_root()
      print(root .. "\\CMakeLists.txt")

      -- Arduinoプロジェクトの場合
      if util.isArduinoProject() then
         -- portを取得
         local handle = io.popen("arduino-cli board list")
         if not handle then
            print("Error: Could not run arduino-cli board list")
            return
         end
         local result = handle:read("*a")
         handle:close()
         local port = result:match("^(COM%d+)") or "COM3"

         local fqbn = "arduino:avr:uno"
         local cmd = string.format([[
         arduino-cli compile --fqbn %s . && arduino-cli upload -p %s --fqbn %s .
         ]], fqbn, port, fqbn)

         util.RunInTerminal(cmd)
         return
      end

      -- avrプロジェクトの場合
      if util.isAvrProject() then
         local root_path_and_toolchain = util.find_project_root() .."\\toolchain-avr.cmake"
         local mmcu_cpu = get_mcu_from_toolchain(root_path_and_toolchain)
         local avrdudge_mcu = shorten_mcu(mmcu_cpu)
         local hex_file = util.getTargetHexFile()
         local avr_build = [[
         cmake --build build --config Debug &&
         avrdude -c atmelice_isp -p ]] ..avrdudge_mcu.. [[ -U flash:w:]]..hex_file

         util.RunInTerminal(avr_build)
         return
      end
      if vim.fn.filereadable(root .. "\\CMakeLists.txt") == 1 then
         -- cmake がある場合
         print("cmake run")
         local exe_file_name = util.getTargetExe()
         print("exe_file_name:" .. exe_file_name)
         local build_strs = [[cmake --build build --config DEBUG&&build\\]]..exe_file_name .. " " .. args
         util.RunInTerminal(build_strs)
      else
         -- cmake がない場合
         local file = vim.fn.expand("%:t")
         local out = vim.fn.expand("%:r") .. ".exe"
         if ext == "c" then
            local biuld_strs = "cl -g -o " .. out .. " " .. file  .. " " .. args
            util.RunInTerminal(biuld_strs)
         elseif ext == "cpp" then
            local build_strs = "cl -g -o " .. out .. " " .. file .. " " .. args
            util.RunInTerminal(build_strs)
         end
      end
   end
end
vim.api.nvim_create_user_command("R", run, {nargs="*"})
-------------------------------- Run Setting End ----------------------------------------

