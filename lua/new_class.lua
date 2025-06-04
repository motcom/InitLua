
local write_class_files = function(name)
 local class_header_src = [[
#pragma once
#include <QWidget>
class ]] .. name .. [[:public QWidget
{
    Q_OBJECT
public:
      explicit ]] .. name .. [[(QWidget *parent = nullptr);
      virtual ~]] .. name .. [[()=default;
};
]]

   local class_cpp_src = [[
#include "]] .. name .. [[.h"
]] .. name .. [[::]] .. name .. [[(QWidget *parent)
    : QWidget(parent)
{
    // Initialization code can go here
}
]]

   local class_header_file_path = name .. ".h"
   local class_cpp_file_path = name .. ".cpp"

   -- ヘッダーファイルを作成
   local class_header_file = io.open(class_header_file_path, "w")
   if class_header_file then
      class_header_file:write(class_header_src)
      class_header_file:close()
   else
      print("Error: Unable to open " .. class_header_file_path .. " for writing.")
   end
   -- ソースファイルを作成
   local class_cpp_file = io.open(class_cpp_file_path, "w")
   if class_cpp_file then
      class_cpp_file:write(class_cpp_src)
      class_cpp_file:close()
   else
      print("Error: Unable to open " .. class_cpp_file_path .. " for writing.")
   end
end

vim.api.nvim_create_user_command("NewClass",  function(opts)
   write_class_files(opts.args)
end,{
   nargs = 1,
   }
)
