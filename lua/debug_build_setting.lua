local util = require("util")

local function debug_build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   if ext == "c" or filename == "CMakeLists.txt" or ext=="cpp"then
      vim.cmd("w!")
      if util.isQt() then
         vim.cmd('!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=gcc.exe -DCMAKE_CXX_COMPILER=g++.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH="C:/Qt/6.9.0/mingw_64/lib/cmake"')
      else
         vim.cmd("!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=gcc.exe -DCMAKE_CXX_COMPILER=g++.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
      end
      vim.cmd("!cmake --build build --config DEBUG")
      vim.fn.system("cp build/compile_commands.json .")
   end
end

vim.api.nvim_create_user_command("Build", debug_build, {})
