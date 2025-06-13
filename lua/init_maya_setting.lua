
local util = require("util")
local common = require("init_cpp_common_setting")

local maya_cmake_src = [[
cmake_minimum_required(VERSION 3.15)
project(MyMayaPlugin)

# Mayaのインストールパス（必要に応じて書き換え）
set(MAYA_LOCATION "C:/Program Files/Autodesk/Maya2025/devkit")

# プラグインのソースファイル
set(SOURCES myPlugin.cpp)

# ライブラリとしてビルド（mll = dll）
add_library(${PROJECT_NAME} SHARED ${SOURCES})

# Maya SDK の include
target_include_directories(${PROJECT_NAME}
    PRIVATE
        "${MAYA_LOCATION}/include"
)

# Maya SDK の lib
target_link_directories(${PROJECT_NAME}
    PRIVATE
        "${MAYA_LOCATION}/lib"
)

# マクロ定義（Maya 2022以降対応）
target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        REQUIRE_IOSTREAM
        _BOOL
        NOMINMAX
)

# Maya ライブラリをリンク
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        OpenMaya
        Foundation
)

# Windows向けに拡張子を.mllに
set_target_properties(${PROJECT_NAME} PROPERTIES
    SUFFIX ".mll"
    PREFIX ""
)
]]

local maya_plugin_cpp_src = [[
#include <maya/MFnPlugin.h>
#include <maya/MPxCommand.h>
#include <maya/MGlobal.h>

// コマンド本体クラス
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

   -- main.cが存在しない場合にのみmain.cppを作成する
   if vim.fn.filereadable(main_cpp_file_path) == 0 then
      local mainc_file = io.open(main_cpp_file_path, "w")
      if mainc_file then
         mainc_file:write(maya_plugin_cpp_src )
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   -- clang format file を作る
   common.create_clangd_format_file()

   -- CMakeLists.txtをビルドしてコンパイルコマンドを生成する
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
