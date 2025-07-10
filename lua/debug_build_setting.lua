local util = require("util")
local common = require("init_cpp_common_setting")
local function debug_build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   -- clang file 作成
   common.create_clangd_format_file()
   if ext == "c" or filename == "CMakeLists.txt" or ext=="cpp" or ext=="h"then
      vim.cmd("w!")

      -- AVRのをビルド
      if util.isAvrProject() then
         -- AVRプロジェクトの場合のビルド設定
         local avr_build = [[
         cmake -S . -B build -G Ninja ^
         -DCMAKE_BUILD_TYPE=Debug ^
         -DCMAKE_TOOLCHAIN_FILE=toolchain-avr.cmake ^
         -DCMAKE_EXPORT_COMPILE_COMMANDS=ON &&
         cmake --build build --config Debug
         ]]
         util.RunInTerminal(avr_build)
         vim.fn.system("cp build/compile_commands.json .")
         return
      end

      -- DCMAKE_PREFIX_PATHを設定するための文字列を作成
      local dcmake_prefix_str = ""
      if util.isQtProject() then -- QtProjectの場合
         local qtlib_path = os.getenv("QTLIB_PATH") or ""
         if qtlib_path == "" then
            print("環境変数QTLIB_PATH がないよ")
            return
         end
         dcmake_prefix_str = dcmake_prefix_str .. qtlib_path
      end

      local build_strs =
      [[cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug ^
      -DCMAKE_CXX_COMPILER=cl.exe ^
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH="]]
      ..dcmake_prefix_str..
      [["&&cmake --build build --config DEBUG]]
      util.RunInTerminal(build_strs)
      vim.fn.system("cp build/compile_commands.json .")
   end
end

vim.api.nvim_create_user_command("Build", debug_build, {})
