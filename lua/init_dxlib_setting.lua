local cmake_file_path = "CMakeLists.txt"
local cmake_dxLib_init = [[
cmake_minimum_required(VERSION 3.10)
project(MyDxLibApp)

set(CMAKE_CXX_STANDARD 17)

# DxLib のパス--環境変数 DXLIB_PATH を使用
set(DXLIB $ENV{DXLIB_PATH})
message(STATUS $ENV{DXLIB_PATH} )

# インクルードディレクトリ
include_directories(${DXLIB})

# ライブラリディレクトリ
link_directories(${DXLIB})

add_executable(MyDxLibApp main.cpp)

target_link_libraries(MyDxLibApp
   DxLib_vs2015_x64_MDd.lib
   DxDrawFunc_vs2015_x64_MDd.lib
   winmm.lib
   dxguid.lib
   dinput8.lib
)

]]

local main_dxlib_file_path = "main.cpp"
local main_dxlib_init = [[
#include "DxLib.h"
namespace dx = DxLib;

int main() {
   const int WIDTH = 640;
   const int HEIGHT = 480;
   const int BLACK = dx::GetColor(0, 0, 0);
   const int WHITE = dx::GetColor(255, 255, 255);
   const int RED = dx::GetColor(255, 0, 0);

   dx::SetMainWindowText("Hello world");
   dx::SetGraphMode(WIDTH, HEIGHT, 32);
   if (dx::DxLib_Init() == -1)
      return -1;
   dx::SetBackgroundColor(0, 0, 0);
   dx::SetDrawScreen(DX_SCREEN_BACK);


   while (1) {

      dx::ClearDrawScreen();

      dx::DrawString(100,100, "Hello World", WHITE);

      dx::ScreenFlip();
      dx::WaitTimer(33);
      if (dx::ProcessMessage() != 0) break;
      if (dx::CheckHitKey(KEY_INPUT_ESCAPE) == 1) break;
   }
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
]]

local write_make_file_dxlib_cpp = function()
   -- cmake_file_pathを作成する
   print("cmake path:" .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(cmake_dxLib_init)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end

   -- main.cppが存在しない場合にのみmain.cppを作成する
   print("main_dxlibfile_path:" .. main_dxlib_file_path)
   if vim.fn.filereadable(main_dxlib_file_path) == 0 then
      local mainc_file = io.open(main_dxlib_file_path, "w")
      if mainc_file then
         mainc_file:write(main_dxlib_init)
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


   vim.cmd(
   "!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
   vim.cmd("!cmake --build build --config DEBUG")

   vim.fn.system("cp build/compile_commands.json .")
end

vim.api.nvim_create_user_command("InitDxLib", write_make_file_dxlib_cpp, {})
