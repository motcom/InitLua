

-- ########### key map grp ###########----------------
local keymap    = vim.api.nvim_set_keymap
local keyopt    = { noremap = true, silent = true }
vim.g.mapleader = " "

-- normal
keymap("n", "<Leader>t", ":Test<CR>", keyopt)
keymap("n", "<Leader>r", ":Run<CR>", keyopt)
keymap("n", "<CR>", "i<CR><ESC>", keyopt)
keymap("n", "0", "^", keyopt)
keymap("n", "^", "0", keyopt)
keymap("n", "s", ":w!<CR>", keyopt)
keymap("n", "<C-f>", "<Plug>(easymotion-overwin-f)", keyopt)
keymap("n", "<Leader>#", ":ColorizerToggle<CR>"
   , { silent = true })
keymap("n", "ga", "<Plug>(EasyAlign)", keyopt)
keymap("x", "ga", "<Plug>(EasyAlign)", keyopt)

-- insert
keymap("i", "jj", "<ESC>", keyopt)
keymap("i", ";;", "<ESC>$A;<CR>", keyopt)
keymap("i", ",,", "<ESC>$A,<CR>", keyopt)
keymap("i", "<C-l>", "<ESC>$A", keyopt)

-- terminal
keymap("t", "<ESC>", "<C-\\><C-n>", keyopt)
keymap("t", "<C-e>", "<C-\\><C-n>:WinResizerStartResize<CR>", keyopt)

keymap("n", "<C-c>", ":Cmd<CR>", keyopt)
keymap("t", "<C-c>", "<C-\\><C-n>:q<CR>", keyopt)

-- MiniMap toggle
keymap("n", "<Leader>m", ":MinimapToggle<CR>", keyopt)
keymap('n', '<Leader><Leader>', ':ToggleFern<CR>', { noremap = true, silent = true })
keymap("n", "<Leader>z", ":ZenMode<CR>", keyopt)

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

-- toggle copilot

local copilot_flag = true
local function toggle_copilot()
   if copilot_flag then
      vim.cmd("Copilot disable")    
      print("copilot disable")
      copilot_flag = false
   else
      vim.cmd("Copilot enable")    
      print("copilot enable")
      copilot_flag = true
   end
end
-- terminal open ----------------------------------------
local function cmd()
   vim.cmd("split")
   vim.cmd("wincmd j")
   vim.cmd("terminal")
   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, true, true), "n", false)
end
vim.api.nvim_create_user_command("Cmd", cmd, {})

-- build -------------------
local function build()
   local ext = vim.fn.expand("%:e")
   if ext == "rs" then
      vim.cmd("w!")
      vim.cmd("!cargo build")
   end
end
vim.api.nvim_create_user_command("Build", build, {})

-- run ----------------------------------------
local function run()
   local ext = vim.fn.expand("%:e")
   if ext == "py" then
      vim.cmd("w!")
      if vim.fn.filereadable("main.py") == 1 then
         vim.cmd("!python main.py")
      else
         vim.cmd("!python %")
      end
   elseif ext == "cs" then
      vim.cmd("w!")
      vim.cmd("!dotnet build")
      vim.cmd("!dotnet run")
   elseif ext == "rs" then
      vim.cmd("w!")
      vim.cmd("!cargo run")
   elseif ext == "lua" then
      vim.cmd("w")
      vim.cmd("!lua %")
   end
end
vim.api.nvim_create_user_command("Run", run, {})

-- test ----------------------------------------
local function test()
   local ext = vim.fn.expand("%:e")
   if ext == "rs" then
      vim.cmd("w!")
      vim.cmd("!cargo test")
   end
end
vim.api.nvim_create_user_command("Test", test, {})
vim.api.nvim_create_user_command("ToggleCopilot", toggle_copilot, {})
keymap("n","<Leader>c",":ToggleCopilot<CR>",{ noremap = true, silent = true })


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
keymap("n","<Leader>n",":ToggleNumber<CR>",{ noremap = true, silent = true }) 


-- set number- ----------------------------------

local my_work = os.getenv("MYHOME") 
local function goto_workspace()
   vim.cmd("cd " .. my_work)
   print("cd " .. my_work)
end
vim.api.nvim_create_user_command("MyHome", goto_workspace, {})
keymap("n","<Leader>h",":MyHome<CR>",{ noremap = true, silent = true })

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
vim.api.nvim_create_user_command("SearchYank", yankMatchingLines, {})

-- yankバッファをすべて削除 ---------------------------------
local function clearAllYankBuffers()
   local regs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-\""
   for i = 1, #regs do
      local reg = regs:sub(i, i)
      vim.fn.setreg(reg, {})
   end
end
vim.api.nvim_create_user_command("ClearBuf", clearAllYankBuffers, {})


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

