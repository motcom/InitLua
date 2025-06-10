local util = require("util")

local function debug_build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   if ext == "c" or filename == "CMakeLists.txt" or ext=="cpp" or ext=="h"then
      vim.cmd("w!")
      if util.isQtProject() then
         local qtlib_path = os.getenv("QTLIB_PATH")
         local build_strs = [[cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH="]]..qtlib_path..[["&&cmake --build build --config DEBUG]]
         util.RunInTerminal(build_strs)
      else
         local biuld_strs = [[cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"&&cmake --build build --config DEBUG]]
      end
      vim.fn.system("cp build/compile_commands.json .")
   end
end

vim.api.nvim_create_user_command("Build", debug_build, {})
