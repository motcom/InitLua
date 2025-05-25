-- cmakelistsを自動生成しmain.cを作成するテンプレートのためのlua
-- 一度biuldしcompiler jsonを作成する

------------------ cmake init start -------------------
local cmake_init = [[
cmake_minimum_required(VERSION 3.10)
project(my_project LANGUAGES CXX)

add_executable(my_project main.cpp)
]]

local cmake_file_path = "CMakeLists.txt"

------------------ cmake init end ---------------------
local main_c_file_path = "main.cpp"
local main_c_init = [[
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
]]

-- clang-formatの設定ファイルを作成する
local clang_format_file_path_c = ".clang-format"
local clang_format_init_c = [[
BasedOnStyle: LLVM
IndentCaseLabels: true
UseTab: Never
TabWidth: 3 
IndentWidth: 3
BreakBeforeBraces: Allman
NamespaceIndentation: All
]]

local write_make_file = function()
   -- clang-formatの設定ファイルを作成する
   print("cmake path:" .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(cmake_init)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end
   print("main_cfile_path:" .. main_c_file_path)

   -- main.cが存在しない場合にのみmain.cを作成する
   if vim.fn.filereadable(main_c_file_path) == 0 then
      local mainc_file = io.open(main_c_file_path, "w")
      if mainc_file then
         mainc_file:write(main_c_init)
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   -- clang-formatの設定ファイルを作成する
   if vim.fn.filereadable(clang_format_file_path_c) == 0 then
      local clang_format_file = io.open(clang_format_file_path_c, "w")
      if clang_format_file then
         clang_format_file:write(clang_format_init_c)
         clang_format_file:close()
      else
         print("Error: Unable to open .clang-format for writing.")
      end
   end

   -- CMakeLists.txtをビルドしてコンパイルコマンドを生成する
   vim.cmd("!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=gcc.exe -DCMAKE_CXX_COMPILER=g++.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
   vim.cmd("!cmake --build build --config DEBUG")
   vim.fn.system("cp build/compile_commands.json .")
end

vim.api.nvim_create_user_command("Initc", write_make_file, {})

