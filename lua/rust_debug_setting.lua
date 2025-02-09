
-- Vimspector options
vim.cmd([[
let g:vimspector_sidebar_width = 40
let g:vimspector_bottombar_height = 15
let g:vimspector_terminal_maxwidth = 40
]])


-- Debug_json

local function find_project_root_rust()
    -- 探索対象のルート判定ファイル/ディレクトリ
    local markers = { ".git", "Cargo.toml" }
    -- カレントディレクトリから上に探索
    local dir = vim.fn.getcwd()
    local dir_tmp = vim.fn.fnamemodify(dir, ":p") -- 正規化されたパス
    local drive = string.sub(dir_tmp, 1, 3) -- ドライブ部分を取得 (例: "C:\")
    while dir ~= drive do
        for _, marker in ipairs(markers) do
            if vim.fn.glob(dir .. "/" .. marker) ~= "" then
                return dir
            end
        end
        -- 一段上に移動
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    return nil -- 見つからない場合
end

-- Debugモードのイニシャライズ
local init_debug_mode = function (opts)

   local args = opts.fargs
   local stdin_arr_str = ""
   local args_arr_str  = ""
   -- 引数がある場合
   if #args > 0 then
      if args[0] == "<" then
         -- パイプ入力
         local nums = #args
         local tmp_table = {}
         for i=1 , nums-1 do
            table.insert(tmp_table,'"' .. args[i] .. '"')
         end
         stdin_arr_str =  '"stdio":['.. table.concat(tmp_table,",") .."],"
      else
         -- パイプ入力以外
         local tmp_table = {}
         for _,w in ipairs(args) do
            table.insert(tmp_table, '"' .. w .. '"' )
         end
         args_arr_str = '"args":[' .. table.concat(tmp_table,",") .. "],"
      end
   end


   local root_path_func = find_project_root_rust()
    -- ルートパスと Cargo.toml のパスを確認
    if not root_path_func then
        print("プロジェクトのルートディレクトリが見つかりません")
        return
    end
    local cargo_toml_path = root_path_func .. "/Cargo.toml"

    -- Cargo.toml ファイルの存在を確認
    local file = io.open(cargo_toml_path, "r")
    if not file then
        print("Cargo.toml が見つかりません: " .. cargo_toml_path)
        return
    end

    -- Cargo.toml の内容を読み取る
    local project_name = nil
    for line in file:lines() do
        local name_match = line:match('^%s*name%s*=%s*"([^"]+)"')
        if name_match then
            project_name = name_match
            break
        end
    end
    file:close()

    -- プロジェクト名が見つからない場合の処理
    if not project_name then
        print("Cargo.toml からプロジェクト名を取得できませんでした")
        return
    end

    -- デバッグメッセージを表示
   local debug_setting = ""
   if root_path_func ~= nil then
      debug_setting = [[{
        "configurations": {
          "launch": {
            "adapter": "CodeLLDB",
            "filetypes": [ "rust" ],
            "configuration": {]] .. "\n" ..
            stdin_arr_str .. "\n" ..
            args_arr_str .. "\n" ..
              [["request": "launch",
              "program": "]]..root_path_func..[[/target/debug/]] ..project_name .. [[.exe"
            },
             "exception": {
                   "cpp_throw": "Y",
                   "cpp_catch": "N"
             }
          }
        }
      }]]
   end


   debug_setting = string.gsub(debug_setting, "\\", "/")
   local table_debug_str = vim.json.decode(debug_setting)
   debug_setting = vim.json.encode(table_debug_str)

   print(debug_setting)
   local file_name = root_path_func .. [[/.vimspector.json]]
   local file_name_normal = string.gsub(file_name, "\\", "/")
   local fp = io.open(file_name_normal,"w")
   print(file_name_normal)
   if fp ~= nil then
      print("write!")
      fp:write(debug_setting)
      fp:close()
   else
      return
   end
end

-- ユーザーコマンドを登録
vim.api.nvim_create_user_command("Debug", init_debug_mode, {nargs="*"})

local map = vim.api.nvim_set_keymap
local opt = {silent=true,noremap=true}
-- Vimspector
map("n","<F5>",":call vimspector#Launch()<cr>",opt)
map('n',"<F6>",":call vimspector#AddWatch()<cr>",opt)
map('n',"<F7>",":call vimspector#Evaluate()<cr>",opt)
map("n","<F8>" ,":call vimspector#Reset()<cr>",opt)
map('n', "<F9>",":call vimspector#ToggleBreakpoint()<cr>",opt)
map("n","<F10>",":call vimspector#StepOver()<cr>",opt)
map("n","<F12>",":call vimspector#StepInto()<cr>",opt)
map("n","<F4>",":call vimspector#StepOut()<cr>",opt)

