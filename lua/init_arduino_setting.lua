
local util = require("util")
local common = require("init_cpp_common_setting")

local cmake_file_path = "CMakeLists.txt"
local main_cpp_file_path = "main.cpp"
local main_cpp_init = [[
#include <Arduino.h>

void setup() {
    pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
    delay(500);
}
]]

-- Arduino core のインクルードパス
local arduino_include = [[
include_directories(
  "C:/Users/motti/AppData/Local/Arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino"
  "C:/Users/motti/AppData/Local/Arduino15/packages/arduino/hardware/avr/1.8.6/variants/standard"
  "C:/Users/motti/AppData/Local/Microsoft/WinGet/Packages/ZakKemble.avr-gcc_Microsoft.Winget.Source_8wekyb3d8bbwe/avr-gcc-14.1.0-x64-windows/avr/include"
)
]]


local cmake_init = [[
cmake_minimum_required(VERSION 3.15)
project(my_arduino_project C CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

add_executable(main main.cpp)

%s
]]

local write_make_file = function(opts)
   -- デフォルトボードとポート
   local board = "arduino:avr:uno"
   local port = "COM3"
   if opts and opts.args and opts.args ~= "" then
      local args = vim.split(opts.args, ",")
      board = args[1] or board
      port = args[2] or port
   end

   -- CMakeLists.txt を生成（補完用のみ）
   print("Generating " .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(cmake_init:format(arduino_include))
      cmake_file:close()
   end

   -- main.cpp を生成（なければ）
   if vim.fn.filereadable(main_cpp_file_path) == 0 then
      local f = io.open(main_cpp_file_path, "w")
      if f then
         f:write(main_cpp_init)
         f:close()
      end
   end

   -- .clang-format, .clangd
   common.create_clangd_format_file()

   -- CMake（補完用コンパイルコマンド生成）
   local cmd = [[
cmake -S . -B build -G Ninja ^
-DCMAKE_C_COMPILER=clang ^
-DCMAKE_CXX_COMPILER=clang++ ^
-DCMAKE_EXPORT_COMPILE_COMMANDS=ON &&
cmake --build build --config Debug
]]
   util.RunInTerminal(cmd)

   -- compile_commands.json コピー
   vim.fn.system("copy build\\compile_commands.json .")

   -- Arduino CLIでビルド & 書き込み（任意）
   -- local upload_cmd = string.format(
   --    [[arduino-cli compile --fqbn %s . && arduino-cli upload -p %s --fqbn %s .]],
   --    board, port, board
   -- )
   -- util.RunInTerminal(upload_cmd)
end

vim.api.nvim_create_user_command("InitArduinoCpp", write_make_file, { nargs = "?" })

