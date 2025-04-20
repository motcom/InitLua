
local function find_project_root_c()
    local markers = { ".git", "main.c", "CMakeLists.txt", "Makefile" }
    local dir = vim.fn.expand('%:p:h') -- 現在のファイルのディレクトリ
    local drive = string.sub(vim.fn.fnamemodify(dir, ":p"), 1, 3)

    while dir and dir ~= drive and dir ~= "" do
        for _, marker in ipairs(markers) do
            if vim.fn.glob(dir .. "/" .. marker) ~= "" then
                return dir
            end
        end
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    return nil
end

local function generate_cmake_file(output_dir, project_name, c_standard)
    project_name = project_name or "MyProject"
    c_standard = c_standard or "11"
    output_dir = output_dir or "."
    local cmake_content =
      'cmake_minimum_required(VERSION 3.10)\n'..
      'project(' .. project_name ..  'C)\n' ..
      'set(CMAKE_C_STANDARD ' .. c_standard .. ')\n' ..
      'add_executable(main main.c)\n'
    local cmake_file_path = output_dir .. "/CMakeLists.txt"
    local file = io.open(cmake_file_path, "w")
    if file then
        file:write(cmake_content)
        file:close()
        print("✅ CMakeLists.txt has been generated at: " .. cmake_file_path)
    else
        print("❌ Failed to write CMakeLists.txt to: " .. cmake_file_path)
    end
end


local function build()
   local compiler_path = os.getenv("C_COMPILER_DIR")
   local ext = vim.fn.expand("%:e")
   if ext == "c" or ext == "CMakeLists.txt" then
      vim.cmd("w!")
      generate_cmake_file(find_project_root_c(), "MyProject", "11")
      local build_command =
      'cmake -B build -G "Ninja" ' ..
        '-DCMAKE_C_COMPILER="'..compiler_path..'/gcc.exe" ' ..
        '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
      vim.fn.system(build_command)
      vim.fn.system("cmake --build build --config DEBUG")
   end
end

vim.api.nvim_create_user_command("Build",build,{})



