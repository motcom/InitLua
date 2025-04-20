
local function build()
   local ext = vim.fn.expand("%:e")
   local filename = vim.fn.expand("%:t")
   if ext == "c" or filename == "CMakeLists.txt" then
      vim.cmd("w!")
      local compiler_path = os.getenv("C_COMPILER_DIR")
      local build_command =
      'cmake -B build -G "Ninja" ' ..
        '-DCMAKE_C_COMPILER="'..compiler_path..'/gcc.exe" ' ..
        '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
      vim.fn.system(build_command)
      vim.fn.system("cmake --build build --config DEBUG")
   end
end

vim.api.nvim_create_user_command("Build",build,{})

