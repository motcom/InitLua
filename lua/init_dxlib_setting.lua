

local cmake_file_path = "CMakeLists.txt"
local cmake_dxLib_init =[[
cmake_minimum_required(VERSION 3.10)
project(MyDxLibApp)

set(CMAKE_CXX_STANDARD 17)

# DxLib のパス--環境変数 DXLIB_PATH を使用
set(DXLIB $ENV{DXLIB_PATH})
message($ENV{DXLIB_PATH} )

# インクルードディレクトリ
include_directories(${DXLIB})

# ライブラリディレクトリ
link_directories(${DXLIB})

add_executable(MyDxLibApp main.cpp)

# MinGWで必要なWindows系ライブラリとDxLibのリンク
target_link_libraries(MyDxLibApp
   DxLib
   DxUseCLib
   DxDrawFunc
   jpeg
   png
   zlib
   tiff
   theora_static
   vorbis_static
   vorbisfile_static
   ogg_static
   bulletdynamics
   bulletcollision
   bulletmath
   opusfile
   opus
   silk_common
   celt 
)

target_include_directories(MyDxLibApp PRIVATE ${DXLIB})
]]


local main_dxlib_file_path = "main.cpp"
local main_dxlib_init = [[
#include "DxLib.h"
namespace dx = DxLib;

int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
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

      if (dx::ClearDrawScreen() != 0)
         break;

      dx::DrawString(100,100, "Hello World", WHITE);

      if (dx::ScreenFlip() != 0)
         break;
      dx::WaitTimer(33);
      if (dx::ProcessMessage() != 0)
         break;
      if (dx::CheckHitKey(KEY_INPUT_ESCAPE) == 1)
         break;
   }

   return 0;
}

]]

local write_make_file_dxlib_cpp = function()
   print("cmake path:" .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(cmake_dxLib_init )
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end

   print("main_dxlibfile_path:" .. main_dxlib_file_path)
   -- main.cが存在しない場合にのみmain.cを作成する
   if vim.fn.filereadable("main.c") == 0 then
      local mainc_file = io.open(main_dxlib_file_path , "w")
      if mainc_file then
         mainc_file:write(main_dxlib_init)
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   vim.cmd("!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=gcc.exe -DCMAKE_CXX_COMPILER=g++.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
   vim.cmd("!cmake --build build --config DEBUG")

   vim.fn.system("cp build/compile_commands.json .")
end

vim.api.nvim_create_user_command("InitDxLib", write_make_file_dxlib_cpp, {})
