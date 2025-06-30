
local util = require("util")
local common = require("init_cpp_common_setting")
------------------ cmake init start -------------------

local cmake_file_path = "CMakeLists.txt"
local cmake_init = [[
cmake_minimum_required(VERSION 3.10)
project(my_project LANGUAGES CXX)

find_package(Open3D REQUIRED)
add_executable(my_project main.cpp)
target_link_libraries(my_project PRIVATE Open3D::Open3D)
]]


------------------ cmake init end ---------------------
local main_cpp_file_path = "main.cpp"
local main_cpp_init = [[

#include <open3d/Open3D.h>

int main() {
    // 点群データを作成
    open3d::geometry::PointCloud pcd;
    pcd.points_.push_back(Eigen::Vector3d(0, 0, 0));
    pcd.points_.push_back(Eigen::Vector3d(1, 0, 0));
    pcd.points_.push_back(Eigen::Vector3d(0, 1, 0));

    // 点群を可視化
    open3d::visualization::DrawGeometries({std::make_shared<open3d::geometry::PointCloud>(pcd)}, "Open3D PointCloud");

    return 0;
}

]]


local write_make_file = function()
   print("cmake path:" .. cmake_file_path)
   local cmake_file = io.open(cmake_file_path, "w")
   if cmake_file then
      cmake_file:write(cmake_init)
      cmake_file:close()
   else
      print("Error: Unable to open CMakeLists.txt for writing.")
   end
   print("main_cfile_path:" .. main_cpp_file_path)

   -- main.cが存在しない場合にのみmain.cppを作成する
   if vim.fn.filereadable(main_cpp_file_path) == 0 then
      local mainc_file = io.open(main_cpp_file_path, "w")
      if mainc_file then
         mainc_file:write(main_cpp_init)
         mainc_file:close()
      else
         print("Error: Unable to open main.c for writing.")
      end
   end

   -- clang format file を作る
   common.create_clangd_format_file()
   

   local Open3D_cmake_path = os.getenv("OPEN3D_CMAKE_PATH")

   -- CMakeLists.txtをビルドしてコンパイルコマンドを生成する
   local cmd = [[
   cmake -S . -B build -G Ninja ^
   -DCMAKE_BUILD_TYPE=Debug ^
   -DCMAKE_CXX_COMPILER=cl.exe ^
   -DCMAKE_PREFIX_PATH=]]..Open3D_cmake_path..[[ ^
   -DCMAKE_EXPORT_COMPILE_COMMANDS=ON&&
   cmake --build build --config DEBUG
   ]]

   util.RunInTerminal(cmd)
   vim.fn.system("cp build/compile_commands.json .")

end

vim.api.nvim_create_user_command("InitOpen3D", write_make_file, {})

