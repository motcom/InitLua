
-- ########### key map grp ###########----------------
local keymap    = vim.api.nvim_set_keymap
local keyopt    = { noremap = true, silent = true }
vim.g.mapleader = " "

-- normal
keymap("n","<Leader>$",":e $MYVIMRC<CR>",keyopt)
keymap("n", "<CR>", "i<CR><ESC>", keyopt)
keymap("n", "0", "^", keyopt)
keymap("n", "^", "0", keyopt)
keymap("n", "f", "<Plug>(easymotion-overwin-f)", keyopt)
keymap("n", "<Leader>#", ":ColorizerToggle<CR>",keyopt)
keymap("n", "<leader>a", "<Plug>(EasyAlign)*", keyopt)
keymap("x", "<leader>a", "<Plug>(EasyAlign)*", keyopt)
keymap("n", "<f2>", "ggVGy<C-o>", keyopt)
keymap("n", "<ESC><ESC>", ":noh",keyopt)
keymap("n", "q", ":q<CR>", keyopt)

vim.keymap.set('n', '<C-k>', vim.diagnostic.open_float, { noremap = true, silent = true })

keymap("n", "<C-n>", ":cnext<CR>", keyopt)
keymap("n", "<C-p>", ":cprev<CR>", keyopt)
keymap("n", "<Tab>", ":bnext<CR>", keyopt)
keymap("n", "<S-Tab>", ":bnext<CR>", keyopt)


-- window move
keymap("n","<leader>h","<C-w>h",keyopt)
keymap("n","<leader>j","<C-w>j",keyopt)
keymap("n","<leader>k","<C-w>k",keyopt)
keymap("n","<leader>l","<C-w>l",keyopt)

-- insert
keymap("i", "jj", "<ESC>", keyopt)
keymap("i", ";;", "<C-o>A;", keyopt)
keymap("i", "<C-l>", "<C-o>a", keyopt)
keymap("i", "<C-h>", "<C-o>h", keyopt)

-- terminal
keymap("t", "<ESC>", "<C-\\><C-n>", keyopt)
keymap("t", "<C-e>", "<C-\\><C-n>:WinResizerStartResize<CR>", keyopt)

keymap("n", "<C-c>", ":Cmd<CR>", keyopt)
keymap("t", "<C-c>", "<C-\\><C-n>:q<CR>", keyopt)

--  message copy
vim.keymap.set('n', '<Leader>m', function()
  vim.cmd('redir @+ | messages | redir END')
end, { desc = 'Copy :messages to clipboard' })

keymap("n", "<Leader><Leader>", ":ToggleFern<CR>", keyopt)
keymap("n", "<Leader>z", ":ZenMode<CR>", keyopt)

-- copilot  toggle
keymap("n", "<Leader>cc", ":CopilotChatToggle<CR>", keyopt)
keymap("n", "<Leader>ce", ":CopilotEnable<CR>", keyopt)
keymap("n", "<Leader>cd", ":CopilotDisable<CR>", keyopt)

keymap("n","<Leader>o",":MyNote<CR>",keyopt)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, keyopt)

-- my note
local function my_note()
   local my_note_path = os.getenv("MYNOTE")
   if my_note_path then
      vim.cmd("cd " .. my_note_path)
      print("Set note dir: " .. my_note_path)
   else
      print("MYNOTE environment variable is not set.")
   end
end
vim.api.nvim_create_user_command("MyNote", my_note, {})

-- copilot toggle function
local function copilot_enable()
   vim.cmd("Copilot enable")
   print("copilot enable")
end
vim.api.nvim_create_user_command("CopilotEnable",copilot_enable, {})

local function copilot_disable()
   vim.cmd("Copilot disable")
   print("copilot disable")
end
vim.api.nvim_create_user_command("CopilotDisable",copilot_disable, {})


-- Fern をトグルする関数
local toggle_fern_flag = false
local function toggle_fern()
   if toggle_fern_flag then
      vim.cmd('FernDo close -stay')
      toggle_fern_flag = false
   else
      vim.cmd('Fern . -drawer')
      toggle_fern_flag = true
   end
end
vim.api.nvim_create_user_command("ToggleFern", toggle_fern, {})


-- json and csv format ----------------------------------
local function format_csv_or_json()
   local file_type = vim.bo.filetype
   print(file_type)
   if file_type  == "json" then
      vim.lsp.buf.format()
   elseif file_type == "rcsv_2c_simple_" then
      vim.cmd("RainbowAlign")
   end
end
vim.api.nvim_create_user_command("FmtCsvOrJson",format_csv_or_json,{})
keymap("n", "<leader>f", ":FmtCsvOrJson<CR>", keyopt)
keymap("n", "<leader>s", ":RainbowShrink<CR>", keyopt)

-- terminal open ----------------------------------------
local function cmd()
   vim.cmd("split")
   vim.cmd("wincmd j")
   vim.cmd("terminal")
   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, true, true), "n", false)
end
vim.api.nvim_create_user_command("Cmd", cmd, {})

------------------------------------------------
-- set number hot key ---------------------------
local function toggle_number()
   if vim.wo.number then
      vim.wo.number = false
   else
      vim.wo.number = true
   end
end
vim.api.nvim_create_user_command("ToggleNumber", toggle_number, {})
keymap("n","<Leader>n",":ToggleNumber<CR>",keyopt)

-- set number end----------------------------------

local my_work = os.getenv("MYWORK")
local function goto_workspace()
   vim.cmd("cd " .. my_work)
   print("cd " .. my_work)
end
vim.api.nvim_create_user_command("MyWork", goto_workspace, {})
keymap("n","<Leader>w",":MyWork<CR>",keyopt)


local my_tmp = os.getenv("MYTMP")
local function goto_tmp()
   vim.cmd("cd " .. my_tmp)
   vim.cmd("w! tmp.py")
   print("cd " .. my_tmp .. "tmp.py")
end
vim.api.nvim_create_user_command("MyTmp", goto_tmp, {})
vim.api.nvim_set_keymap("n", "<Leader>t", ":MyTmp<CR>", keyopt)


-- my function ----------------------------------
local function yankMatchingLines()
   -- 最後の検索パターンを取得
   local pattern = vim.fn.histget('search', -1)

   -- マッチする行を格納するテーブル
   local matching_lines = {}

   -- 全行をループし、パターンにマッチするか確認
   for i = 1, vim.fn.line('$') do
      local line = vim.fn.getline(i)
      if pattern == nil then
         return
      end
      if string.find(line, pattern) then
         table.insert(matching_lines, line)
      end
   end

   -- テーブルの内容を文字列に変換
   local text_to_yank = table.concat(matching_lines, "\n")

   -- yankバッファにテキストを挿入
   vim.fn.setreg('a', text_to_yank)
end

-- バッファを処理して更新する
vim.api.nvim_create_user_command("Sy", yankMatchingLines, {})

-- yankバッファをすべて削除 ---------------------------------
local function clearAllYankBuffers()
   local regs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-\""
   for i = 1, #regs do
      local reg = regs:sub(i, i)
      vim.fn.setreg(reg, "")
   end
end
vim.api.nvim_create_user_command("Cb", clearAllYankBuffers, {})

-- Cargo modules Tree viewer -----------------------------------
vim.api.nvim_create_user_command('TreeLib', function()
    vim.cmd('botright new')
    vim.cmd('terminal cargo-modules structure --lib')
    vim.cmd('startinsert')
end, {})
vim.api.nvim_create_user_command('Tree', function()
    vim.cmd('botright new')
    vim.cmd('terminal cargo_modules_binary')
    vim.cmd('startinsert')
end, {})

-- copy diagnostics to clipboard
vim.api.nvim_set_keymap('n', 'yd', '<cmd>lua CopyDiagnosticsToClipboard()<CR>', keyopt)
function CopyDiagnosticsToClipboard()
  local diagnostics = vim.diagnostic.get(0, {lnum = vim.fn.line('.') - 1})
  if #diagnostics > 0 then
    local message = diagnostics[1].message
    vim.fn.setreg('+', message)  -- クリップボードにコピー
    print(message)
  else
    print("No diagnostics at current line")
  end
end

-- Format
vim.api.nvim_create_user_command('Fmt', function()
    vim.lsp.buf.format()
end, {})


-- toggle header cpp
vim.api.nvim_create_user_command('ToggleCppHeader', function()
    local file_path = vim.fn.expand('%:p')
    if file_path:match('%.cpp$') then
        local header_path = file_path:gsub('%.cpp$', '.h')
        if vim.fn.filereadable(header_path) == 1 then
            vim.cmd('edit ' .. header_path)
        else
            print("Header file does not exist: " .. header_path)
        end
    elseif file_path:match('%.h$') then
        local cpp_path = file_path:gsub('%.h$', '.cpp')
        if vim.fn.filereadable(cpp_path) == 1 then
            vim.cmd('edit ' .. cpp_path)
        else
            print("Source file does not exist: " .. cpp_path)
        end
    else
        print("Not a .cpp or .h file: " .. file_path)
    end
end, {})

-- Keymap for toggling header files in C/C++ project_files  
vim.api.nvim_set_keymap('n', '<F4>', ':ToggleCppHeader<CR>', keyopt)

