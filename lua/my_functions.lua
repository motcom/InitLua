vim.api.nvim_create_user_command('Sum', function()
   local total = 0
   for i = 1, vim.fn.line('$') do
     local line = vim.fn.getline(i)
     local amount = line:match("|%d+/%d+|([%d,]+)|")
     if amount then
       total = total + tonumber((amount:gsub(",", "")))
     end
   end
   local total_str = tostring(total)
    total_str = total_str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    print("total: " .. total_str)
   vim.fn.setreg('+', "|total:|"..total_str.."|||")
end,{})


vim.api.nvim_create_user_command('Graph', function()
  local file_name =  vim.api.nvim_buf_get_name(0)
  local file_name = file_name:gsub("\\","\\\\")
  print("file_name:"..file_name)
  local py_code = string.format([=[
# -*- coding: shift-jis -*-
import matplotlib.pyplot as plt
import re
import matplotlib
import os

file_name = "]=] ..file_name..[=["
matplotlib.rcParams['font.family'] = 'MS Gothic' 
pattern = r"\|(\d{2}/\d{2})\|([\d,]+)\|([^\|]+)\|([^\|]+)\|"
with open(file_name, 'r', encoding='shift-jis') as file:
    lines = re.findall(pattern, file.read())

total_dict = {}
for line in lines:
    if line[2] in total_dict:
        total_dict[line[2]] += int(line[1].replace(',', ''))
    else:
        total_dict[line[2]] = int(line[1].replace(',', ''))

plt.figure(figsize=(10, 6))
title = os.path.basename(file_name)
year, month = title.split("_")[0], title.split("_")[1].split(".")[0]
plt.title(f"{year}年{month}月の支出")
plt.pie(list(total_dict.values()), labels=list(total_dict.keys()), autopct='%%1.1f%%%%')
plt.show()
]=], file_name:gsub("\\", "\\\\")) -- Windows向けにパスのバックスラッシュをエスケープ

  local tmp_path = vim.fn.tempname() .. ".py"
  local f = io.open(tmp_path, "w")
  if not f then
    print("ファイル書き込みに失敗しました: " .. tmp_path)
    return
  end
  f:write(py_code)
  f:close()

  -- Pythonスクリプト実行（同期）
  local result_str = string.format('python "%s"', tmp_path)
  print("result:"..result_str)
  local handle = io.popen(result_str)
   if not handle then
      print("Pythonスクリプトの実行に失敗しました")
      return
   end
  local output = handle:read("*a")
  handle:close()
  print(output)
end, {})
