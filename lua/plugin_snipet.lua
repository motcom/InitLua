-- Vim Snipet Base Setting Start --------------------------------------------------
local luasnip = require("luasnip")
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
vim.api.nvim_set_keymap("i", "<C-k>", "<cmd>lua require'luasnip'.expand_or_jump()<CR>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<C-j>", "<cmd>lua require'luasnip'.jump(-1)<CR>", {silent = true, noremap = true})
-- Vim Snipet Base Setting End  --------------------------------------------------

