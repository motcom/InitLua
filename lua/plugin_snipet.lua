

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Vim Snipet Base Setting Start --------------------------------------------------
ls.add_snippets("make", {
  s("make", {
      t({
      "CC = gcc",
      "CFLAGS = -Wall -O0 -g  # debug",
      "#CFLAGS = -O2 -march=native  # release",
      "SRCS =  $(wildcard *.c)",
      "OBJS = $(SRCS:.c=.o)",
      "TARGET = tst.exe",
      "",
      "$(TARGET):$(OBJS)",
      "\t$(CC) -o $@ $(OBJS)",
      "%.o:%.c",
      "\t$(CC) $(CFLAGS) -c $< -o $@",
      "",
      "-include $(SRCS:.c=.d)",
      "",
      "run:$(TARGET)",
      "\t$(TARGET) $(ARGS)",
      "",
      "clean:",
      "\trm -f *.o *.exe *.d",
      "",
      ".PHONY:all clean"
      }),
  })
})

-- <C-k> でスニペットを展開・次のノードに移動
vim.keymap.set({ "i", "s" }, "<C-k>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

-- <C-j> で前のノードに戻る（任意）
vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })
