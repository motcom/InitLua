
local util = require("util")
local common = require("init_cpp_common_setting")


------------------ cmake init start -------------------
local tool_chain_file_path = "toolchain-avr.cmake"
local tool_chain_file_strs = [[
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)
set(CMAKE_OBJCOPY avr-objcopy)
set(CMAKE_SIZE avr-size)
set(CMAKE_AR avr-ar)
set(CMAKE_RANLIB avr-ranlib)
set(CMAKE_LINKER avr-ld)
set(CMAKE_NM avr-nm)
set(CMAKE_STRIP avr-strip)
set(CMAKE_C_FLAGS "-mmcu=%s")
set(CMAKE_CXX_FLAGS "-mmcu=%s")
set(CMAKE_EXE_LINKER_FLAGS "-mmcu=%s")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
]]

local cmake_file_path = "CMakeLists.txt"
local cmake_init = [[

cmake_minimum_required(VERSION 3.15)
project(my_avr_project C)

# MCU �ݒ�i�K�v�ɉ����ĕύX�j
set(MCU %s)

# CMake��AVR�p�ł��邱�Ƃ�`����
set(CMAKE_SYSTEM_NAME Generic)

# �R���p�C���𖾎��I�ɐݒ�
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)

# �t���O�ݒ�
set(CMAKE_C_FLAGS "-mmcu=${MCU} -Os" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "-mmcu=${MCU} -Os" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "-mmcu=${MCU}" CACHE STRING "" FORCE)

# ���s�t�@�C���i.elf�j�쐬
add_executable(main.elf main.c)

# HEX �t�@�C�������������iavrdude�Ȃǂŏ������ޗp�j
add_custom_command(TARGET main.elf POST_BUILD
    COMMAND avr-objcopy -O ihex main.elf main.hex
    COMMENT "Generating main.hex"
)
]]

------------------ cmake init end ---------------------
local main_c_file_path = "main.c"
local main_c_init = [[
#define F_CPU 8000000UL // �N���b�N���g����ݒ�i16MHz�j
#include <avr/io.h>
#include <util/delay.h>

int main(void) {
    DDRB |= (1 << PB0); // PB0���o�͂ɐݒ�
    while (1) {
        PORTB ^= (1 << PB0); // �g�O��
        _delay_ms(500);
    }
    return 0;
}
]]

local write_make_file = function(opts)
   local mcu = "attiny2313" -- �f�t�H���g��MCU��ݒ�
   if opts and opts.args and opts.args ~= "" then
      mcu = opts.args
   end

   -- toolchain�t�@�C�����쐬����
   print("toolchain file path:" .. tool_chain_file_path)
   local tool_chain_file = io.open(tool_chain_file_path, "w")
   if tool_chain_file then
      tool_chain_file:write(tool_chain_file_strs:format(mcu, mcu, mcu))
      tool_chain_file:close()
   else
      print("Error: Unable to open toolchain file for writing.")
   end

   -- CMakeLists.txt���쐬����
   print("cmake path:" .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      local cmake_content = cmake_init:format(mcu)
      cmake_file:write(cmake_content)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end
   print("main_cfile_path:" .. main_c_file_path)

   -- main.c�����݂��Ȃ��ꍇ�ɂ̂�main.c���쐬����
   if vim.fn.filereadable(main_c_file_path) == 0 then
      local mainc_file = io.open(main_c_file_path, "w")
      if mainc_file then
         mainc_file:write(main_c_init)
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   -- clang format file �����
   common.create_clangd_format_file()

   -- CMakeLists.txt���r���h���ăR���p�C���R�}���h�𐶐�����
   local cmd = [[
   cmake -S . -B build -G Ninja ^
   -DCMAKE_BUILD_TYPE=Debug ^
   -DCMAKE_TOOLCHAIN_FILE=toolchain-avr.cmake ^
   -DCMAKE_EXPORT_COMPILE_COMMANDS=ON &&
   cmake --build build --config Debug
   ]]
   util.RunInTerminal(cmd)
   vim.fn.system("cp build/compile_commands.json .")
end

vim.api.nvim_create_user_command("InitAvr", write_make_file, {nargs = "?"})
