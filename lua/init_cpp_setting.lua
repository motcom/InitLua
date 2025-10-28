local util = require("util")
local common = require("init_cpp_common_setting")
------------------ cmake init start -------------------
local cmake_file_path = "CMakeLists.txt"
local cmake_init = [[
cmake_minimum_required(VERSION 3.10)
project(my_project LANGUAGES CXX)

add_executable(my_project main.cpp)
]]


------------------ cmake init end ---------------------
local main_cpp_file_path = "main.cpp"
local main_cpp_init = [[
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
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
   print("main_cfile_path:" .. main_cpp_file_path)

   -- main.cが存在しない場合にのみmain.cppを作成する
   if vim.fn.filereadable(main_cpp_file_path) == 0 then
      local mainc_file = io.open(main_cpp_file_path, "w")
      if mainc_file then
         mainc_file:write(main_cpp_init)
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   -- clang format file を作る
   common.create_clangd_format_file()

   -- CMakeLists.txtをビルドしてコンパイルコマンドを生成する
   local uname = vim.loop.os_uname().sysname
   local cmd = ""

   if uname == "Windows_NT" then
       -- Windows用（MSVC）
       cmd = [[
   cmake -S . -B build -G Ninja ^
   -DCMAKE_BUILD_TYPE=Debug ^
   -DCMAKE_C_COMPILER=cl.exe ^
   -DCMAKE_CXX_COMPILER=cl.exe ^
   -DCMAKE_EXPORT_COMPILE_COMMANDS=ON &&
   cmake --build build --config DEBUG
   ]]
   else
       -- Linux用（GCC）
       cmd = [[
   cmake -S . -B build -G Ninja \
   -DCMAKE_BUILD_TYPE=Debug \
   -DCMAKE_C_COMPILER=gcc \
   -DCMAKE_CXX_COMPILER=g++ \
   -DCMAKE_EXPORT_COMPILE_COMMANDS=ON &&
   cmake --build build --config Debug
   ]]
   end

   util.RunInTerminal(cmd)
   vim.fn.system("cp build/compile_commands.json .")

end

vim.api.nvim_create_user_command("InitCpp", write_make_file, {})

