-- Vim Snipet Base Setting Start --------------------------------------------------
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- Vim Snipet Base Setting End  --------------------------------------------------

ls.add_snippets("make", {
   s("make", {
      t({
         "CC = gcc",
         "CFLAGS = -Wall -O0 -g",
         "#CFLAGS =  -O2 -march=native",
         "SRCS =  $(wildcard *.c)",
         "OBJS = $(SRCS:.c=.o)",
         "TARGET = tst.exe",
         "",
         "run:$(TARGET)",
         "\t./$(TARGET)",
         "",
         "$(TARGET):$(OBJS)",
         "\t$(CC) -o $@ $(OBJS)",
         "%.o:%.c",
         "\t$(CC) $(CFLAGS) -c $< -o $@",
         "",
         "-include $(SRCS:.c=.d)",
         "",
         "clean:",
         "\trm -f *.o *.exe *.d",
         "",
         ".PHONY:all clean"
      })
   })
})
