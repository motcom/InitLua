
local common = require("init_cpp_common_setting")
local util = require("util")

local cmake_file_path = "CMakeLists.txt"
local cmake_sdl2_init = [[

cmake_minimum_required(VERSION 3.10)
project(MySDL2App)

set(CMAKE_CXX_STANDARD 17)

find_package(SDL2 REQUIRED)
include_directories(${SDL2_INCLUDE_DIRS})

add_executable(MySDL2App main.cpp)
target_link_libraries(MySDL2App ${SDL2_LIBRARIES})

]]

local main_sdl2_file_path = "main.cpp"
local main_sdl2_init = [[

#include <SDL.h>
#include <iostream>

int main() {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        std::cerr << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return 1;
    }
    SDL_Quit();
    return 0;
}

]]


local write_make_file_sdl2_cpp = function()
   -- cmake_file_path‚ðì¬‚·‚é
   print("cmake path:" .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(cmake_sdl2_init)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end

   -- main.cpp‚ª‘¶Ý‚µ‚È‚¢ê‡‚É‚Ì‚Ýmain.cpp‚ðì¬‚·‚é
   print("main_sdl2file_path:" .. main_sdl2_file_path)
   if vim.fn.filereadable(main_sdl2_file_path) == 0 then
      local mainc_file = io.open(main_sdl2_file_path, "w")
      if mainc_file then
         mainc_file:write(main_sdl2_init)
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   -- clang-format‚ÌÝ’èƒtƒ@ƒCƒ‹‚ðì¬‚·‚é
   common.create_clangd_format_file()

   vim.cmd("!cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=g++.exe -DCMAKE_CXX_COMPILER=g++.exe -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
   vim.cmd("!cmake --build build --config DEBUG")

   vim.fn.system("cp build/compile_commands.json .")
end

vim.api.nvim_create_user_command("Initsdl2", write_make_file_sdl2_cpp, {})
