-- cmakelistsを自動生成しmain.cを作成するテンプレートのためのlua
-- 一度biuldしcompiler jsonを作成する


------------------ cmake init start -------------------
local cmake_init = [[
cmake_minimum_required(VERSION 3.10)
project(my_project LANGUAGES C)

add_executable(my_project main.c)
]]

local cmake_file_path = "CMakeLists.txt"
------------------ cmake init end ---------------------

local main_c_file_path = "main.c"
local main_c_init = [[
#include <stdio.h>

int main() {
    printf("Hello, World!\\n");
    return 0;
}
]]


local write_make_file = function()
   print("cmake path:" .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(cmake_init)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end

   print("main_cfile_path:" .. main_c_file_path)
   local mainc_file = io.open(main_c_file_path, "w")
   if mainc_file then
      mainc_file:write(main_c_init)
      mainc_file:close()
   else
      print("Error: Unable to open main.c for writing.")
   end
   vim.cmd("!cmake -S . -B build -G \"Visual Studio 17 2022\" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
   vim.cmd("!cmake --build build --config DEBUG")
   vim.fn.system("cp build/compile_commands.json .")
end


vim.api.nvim_create_user_command("Initc", write_make_file, {})
