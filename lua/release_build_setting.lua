local util = require("util")
local function release_build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   if ext == "c" or filename == "CMakeLists.txt" or ext == "cpp" then
      vim.cmd("w!")
      if util.isQtProject() then
         local qtlib_path = os.getenv("QTLIB_PATH")
         vim.cmd('!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe -DCMAKE_PREFIX_PATH="' .. qtlib_path .. '"')
      elseif util.isAvrProject() then
         vim.cmd('!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=toolchain-avr.cmake')
      else
         vim.cmd("!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe ")
      end
      vim.cmd("!cmake --build build --config Release")
      vim.fn.system("cp build/compile_commands.json .")

      elseif ext=="rs" then
      local rust_release = [[
         cargo build
      ]]
      util.RunInTerminal(rust_release)
   end
end

vim.api.nvim_create_user_command("Release", release_build, {})
