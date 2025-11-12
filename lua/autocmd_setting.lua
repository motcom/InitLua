
-- フォールディングをexprに設定し、treesitterのfoldexprを使用
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false -- デフォルトでフォールドを開いた状態にする


-- ==== Slint preview: simple & robust (Windows / Linux / macOS) ====
local group = vim.api.nvim_create_augroup("SlintPreview", { clear = true })

-- Neovim が起動した slint-viewer のジョブIDを保持
vim.g.slint_viewer_jobid = nil

local function start_viewer(file)
  local exe = vim.fn.exepath("slint-viewer")
  if exe == "" then
    vim.notify("slint-viewer が見つかりません。`cargo install slint-viewer` と PATH を確認してください。", vim.log.levels.ERROR)
    return
  end
  -- 配列で渡してパスの空白・クォート問題を回避（OS共通）
  local jid = vim.fn.jobstart({ exe, file }, {
    detach = false,  -- jobstop で確実に止めたい
  })
  if jid > 0 then
    vim.g.slint_viewer_jobid = jid
  else
    vim.notify("slint-viewer の起動に失敗しました。", vim.log.levels.ERROR)
  end
end

local function stop_viewer(cb)
  local jid = vim.g.slint_viewer_jobid
  if jid and jid > 0 then
    pcall(vim.fn.jobstop, jid)
    -- Windows で GUI プロセス終了が遅れることがあるので少し待つ
    vim.defer_fn(function()
      vim.g.slint_viewer_jobid = nil
      if cb then cb() end
    end, 200)
  else
    if cb then cb() end
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.slint",
  callback = function(args)
    -- ① まず Neovim 管理の旧プロセスを stop（外部 kill しない）
    stop_viewer(function()
      -- ② 終了を少し待ってから再起動
      start_viewer(args.file)
    end)
  end,
})
-- ================================================================
