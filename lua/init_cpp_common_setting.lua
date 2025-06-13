
M ={}

function M.create_clangd_format_file()
   -- clang-formatの設定ファイルを作成する
   local clang_format_file_path_cpp = ".clang-format"
   local clang_format_init_cpp = [[
   BasedOnStyle: LLVM
   IndentCaseLabels: true
   UseTab: Never
   TabWidth: 3 
   IndentWidth: 3
   BreakBeforeBraces: Allman
   NamespaceIndentation: All
   ]]

   -- clang-formatの設定ファイルを作成する
   if vim.fn.filereadable(clang_format_file_path_cpp) == 0 then
      local clang_format_file = io.open(clang_format_file_path_cpp, "w")
      if clang_format_file then
         clang_format_file:write(clang_format_init_cpp)
         clang_format_file:close()
      else
         print("Error: Unable to open .clang-format for writing.")
      end
   end
end

return M
