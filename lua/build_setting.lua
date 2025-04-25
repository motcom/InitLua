

local function build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   if ext == "c" or filename == "CMakeLists.txt" then
      vim.cmd("w!")
   vim.cmd('!cmake -S . -B build -G "Ninja" -DCMAKE_C_COMPILER=gcc.exe -DCMAKE_C_COMPILER_FRONTEND_VARIANT=GNU -DCMAKE_EXPORT_COMPILE_COMMANDS=ON')
      vim.cmd("!cmake --build build --config DEBUG")
      vim.fn.system("cp build/compile_commands.json .")
   end
end

vim.api.nvim_create_user_command("Build", build, {})
