local util = require("util")
local common = require("init_cpp_common_setting")
local function debug_build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   -- clang file �쐬
   common.create_clangd_format_file()
   if ext == "c" or filename == "CMakeLists.txt" or ext=="cpp" or ext=="h"then
      vim.cmd("w!")

      -- AVR�̂��r���h
      if util.isAvrProject() then
         -- AVR�v���W�F�N�g�̏ꍇ�̃r���h�ݒ�
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

      -- DCMAKE_PREFIX_PATH��ݒ肷�邽�߂̕�������쐬
      local dcmake_prefix_str = ""
      if util.isQtProject() then -- QtProject�̏ꍇ
         local qtlib_path = os.getenv("QTLIB_PATH") or ""
         if qtlib_path == "" then
            print("���ϐ�QTLIB_PATH ���Ȃ���")
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
