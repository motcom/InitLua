-- cmakelistsを自動生成しmain.cを作成するテンプレートのためのlua
-- 一度biuldしcompiler jsonを作成する

------------------ cmake init start -------------------
local cmake_init_qt = [[
cmake_minimum_required(VERSION 3.16)
project(MyQtApp)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

add_executable(MyQtApp
    main.cpp
)

target_link_libraries(MyQtApp PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets)
]]

local cmake_file_path_qt = "CMakeLists.txt"
------------------ cmake init end ---------------------

local main_c_file_path_qt = "main.cpp"
local main_c_init_qt = [[
#include <QApplication>
#include <QMainWindow>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QMainWindow window;
    window.show();

    return app.exec();
}

]]

-- clang-formatの設定ファイルを作成する
local clang_format_file_path_qt = ".clang-format"
local clang_format_init_qt = [[
BasedOnStyle: LLVM
IndentCaseLabels: true
UseTab: Never
TabWidth: 3 
IndentWidth: 3
BreakBeforeBraces: Allman
NamespaceIndentation: All
]]

local write_make_file_qt = function()
   -- clang-formatの設定ファイルを作成する
   print("cmake path:" .. cmake_file_path_qt)
   local cmake_file = io.open(cmake_file_path_qt, "w")
   if cmake_file then
      cmake_file:write(cmake_init_qt)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end
   print("main_cfile_path:" .. main_c_file_path_qt)

   -- main.cが存在しない場合にのみmain.cを作成する
   if vim.fn.filereadable(main_c_file_path_qt) == 0 then
      local mainc_file = io.open(main_c_file_path_qt, "w")
      if mainc_file then
         mainc_file:write(main_c_init_qt)
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   -- clang-formatの設定ファイルを作成する
   if vim.fn.filereadable(clang_format_file_path_qt) == 0 then
      local clang_format_file = io.open(clang_format_file_path_qt, "w")
      if clang_format_file then
         clang_format_file:write(clang_format_init_qt)
         clang_format_file:close()
      else
         print("Error: Unable to open .clang-format for writing.")
      end
   end

   -- CMakeLists.txtをビルドしてコンパイルコマンドを生成する
   vim.cmd('!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=gcc.exe -DCMAKE_CXX_COMPILER=g++.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH="C:/Qt/6.9.0/mingw_64/lib/cmake"')
   vim.cmd("!cmake --build build --config DEBUG")

   vim.fn.system("cp build/compile_commands.json .")
end



vim.api.nvim_create_user_command("InitQt", write_make_file_qt, {})
