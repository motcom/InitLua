-- cmakelistsを自動生成しmain.cを作成するテンプレートのためのlua
-- 一度biuldしcompiler jsonを作成する
local util = require("util")
local common = require("init_cpp_common_setting")




local write_make_file_qt_obj = function(opts)
   local base_name = opts.args or "MyQtApp"
   if base_name == "" then
      base_name = "MyQtApp"
   end

   local split_names = vim.split(base_name, "_")

   for i, name in ipairs(split_names) do
      split_names[i] = name:sub(1, 1):upper() .. name:sub(2)
   end
   local class_name  = table.concat(split_names, "")

   print("base_name:" .. base_name)
   print("class_name:" .. class_name)





------------------ cmake init start -------------------
local cmake_init_qt = string.format([[
cmake_minimum_required(VERSION 3.16)
project(MyQtApp)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

add_executable(MyQtApp
    main.cpp
    %s.cpp
)

target_link_libraries(MyQtApp PRIVATE Qt6::Core)
]],base_name)

local cmake_file_path_qt = "CMakeLists.txt"
------------------ cmake init end ---------------------

local main_cpp_file_path_qt = "main.cpp"
local main_cpp_init_qt = string.format([[
#include "%s.h"
#include <QObject>

int main(int argc, char *argv[])
{

   %s obj;
   obj.print();

}
]],base_name, class_name)


local wid_header_file_path_qt = base_name..".h"
local wid_header_src = string.format([[
#pragma once
#include <QObject>

class %s : public QObject
{
   Q_OBJECT
public:
   %s();
   virtual ~%s()=default;
   void print() { qDebug("Hello qt ob!"); }

};
]], class_name, class_name, class_name)


local wid_cpp_file_path_qt = base_name .. ".cpp"
local wid_cpp_src = string.format([[
#include "%s.h"

%s::%s()
    : QObject()
{
}  
]], base_name, class_name, class_name)

   -- clang-formatの設定ファイルを作成する
   print("cmake path:" .. cmake_file_path_qt)
   local cmake_file = io.open(cmake_file_path_qt, "w")
   if cmake_file then
      cmake_file:write(cmake_init_qt)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end
   print("main_cfile_path:" .. main_cpp_file_path_qt)

   -- main.cppが存在しない場合にのみmain.cを作成する
   if vim.fn.filereadable(main_cpp_file_path_qt) == 0 then
      local mainc_file = io.open(main_cpp_file_path_qt, "w")
      local wid_header_file = io.open(wid_header_file_path_qt, "w")
      local wid_cpp_file = io.open(wid_cpp_file_path_qt, "w")
      if wid_header_file then
         wid_header_file:write(wid_header_src)
         wid_header_file:close()
      else
         print("Error: Unable to open MainWid.h for writing.")
      end
      if wid_cpp_file then
         wid_cpp_file:write(wid_cpp_src)
         wid_cpp_file:close()
      else
         print("Error: Unable to open MainWid.cpp for writing.")
      end
      if mainc_file then
         mainc_file:write(main_cpp_init_qt)
         mainc_file:close()

      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   common.create_clangd_format_file()

   local qtlib_path = os.getenv("QTLIB_PATH")
   -- CMakeLists.txtをビルドしてコンパイルコマンドを生成する

   local uname = vim.loop.os_uname().sysname
   local cmake_str = ""
   if uname == "Windows_NT" then
      -- Windows用 (MSVC)
      cmake_str =
      [[cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug ^
      -DCMAKE_C_COMPILER=cl.exe ^
      -DCMAKE_CXX_COMPILER=cl.exe ^
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ^
      -DCMAKE_PREFIX_PATH="]] .. qtlib_path ..
      [[" && cmake --build build --config DEBUG]]
   else
      -- Linux / macOS 用 (g++)
      cmake_str =
      [[cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_COMPILER=gcc \
      -DCMAKE_CXX_COMPILER=g++ \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DCMAKE_PREFIX_PATH="]] .. qtlib_path ..
      [[" && cmake --build build --config Debug]]
   end

   print("cmake_str:" .. cmake_str)
   util.RunInTerminal(cmake_str)
   vim.fn.system("cp build/compile_commands.json .")
end

vim.api.nvim_create_user_command("InitQtObj", write_make_file_qt_obj, {nargs = 1})
