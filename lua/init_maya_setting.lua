
local util = require("util")
local common = require("init_cpp_common_setting")

local maya_cmake_src = [[
cmake_minimum_required(VERSION 3.15)
project(MyMayaPlugin)

# Maya�̃C���X�g�[���p�X�i�K�v�ɉ����ď��������j
set(MAYA_LOCATION "C:/Program Files/Autodesk/Maya2025/devkit")

# �v���O�C���̃\�[�X�t�@�C��
set(SOURCES myPlugin.cpp)

# ���C�u�����Ƃ��ăr���h�imll = dll�j
add_library(${PROJECT_NAME} SHARED ${SOURCES})

# Maya SDK �� include
target_include_directories(${PROJECT_NAME}
    PRIVATE
        "${MAYA_LOCATION}/include"
)

# Maya SDK �� lib
target_link_directories(${PROJECT_NAME}
    PRIVATE
        "${MAYA_LOCATION}/lib"
)

# �}�N����`�iMaya 2022�ȍ~�Ή��j
target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        REQUIRE_IOSTREAM
        _BOOL
        NOMINMAX
)

# Maya ���C�u�����������N
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        OpenMaya
        Foundation
)

# Windows�����Ɋg���q��.mll��
set_target_properties(${PROJECT_NAME} PROPERTIES
    SUFFIX ".mll"
    PREFIX ""
)
]]

local maya_plugin_cpp_src = [[
#include <maya/MFnPlugin.h>
#include <maya/MPxCommand.h>
#include <maya/MGlobal.h>

// �R�}���h�{�̃N���X
class HelloWorldCmd : public MPxCommand {
public:
    HelloWorldCmd() {}
    virtual ~HelloWorldCmd() {}

    static void* creator() {
        return new HelloWorldCmd();
    }

    MStatus doIt(const MArgList& args) override {
        MGlobal::displayInfo("Hello, Maya!");
        return MS::kSuccess;
    }
};


MStatus initializePlugin(MObject obj) {
    MFnPlugin plugin(obj, "YourName", "1.0", "Any");
    return plugin.registerCommand("helloWorld", HelloWorldCmd::creator);
}

MStatus uninitializePlugin(MObject obj) {
    MFnPlugin plugin(obj);
    return plugin.deregisterCommand("helloWorld");
}
]]

local cmake_file_path = "CMakeLists.txt"
local main_cpp_file_path = "myPlugin.cpp"
local write_make_file_maya = function()
   print("cmake path:" .. maya_cmake_src )
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(maya_cmake_src)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end
   print("main_cfile_path:" .. main_cpp_file_path)

   -- main.c�����݂��Ȃ��ꍇ�ɂ̂�main.cpp���쐬����
   if vim.fn.filereadable(main_cpp_file_path) == 0 then
      local mainc_file = io.open(main_cpp_file_path, "w")
      if mainc_file then
         mainc_file:write(maya_plugin_cpp_src )
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
   -DCMAKE_C_COMPILER=cl.exe ^
   -DCMAKE_CXX_COMPILER=cl.exe ^
   -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ^
   &&cmake --build build --config DEBUG
   ]]

   util.RunInTerminal(cmd)
   vim.fn.system("cp build/compile_commands.json .")

end

vim.api.nvim_create_user_command("InitMayaCmd",write_make_file_maya  , {})
