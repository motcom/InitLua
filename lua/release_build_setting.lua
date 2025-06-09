local util = require("util")
local function release_build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   if ext == "c" or filename == "CMakeLists.txt" or ext=="cpp"then
      vim.cmd("w!")
      if util.isQtProject() then
         local qtlib_path = os.getenv("QTLIB_PATH")
         vim.cmd('!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH="'..qtlib_path..'"')
      else
         vim.cmd("!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
      end
      vim.cmd("!cmake --build build --config Release")
      vim.fn.system("cp build/compile_commands.json .")
   end
end

vim.api.nvim_create_user_command("Release", release_build, {})
