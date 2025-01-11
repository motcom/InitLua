
-- CopilotChatの設定
require("CopilotChat").setup({
    show_help = "yes",
    chat_autocomplete = false,
    window = {
      layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace'
      width = 0.3, -- fractional width of parent, or absolute width in columns when > 1
      height = 0.3, -- fractional height of parent, or absolute height in rows when > 1
      -- Options below only apply to floating windows
      relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
      border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
      row = nil, -- row position of the window, default is centered
      col = nil, -- column position of the window, default is centered
      title = 'Copilot Chat', -- title of chat window
      footer = nil, -- footer of chat window
      zindex = 1, -- determines if window is on top or below other floating windows
    },
     -- default mappings
    mappings = {
      complete = {
        insert = '<Tab>',
        
      },
      close = {
        normal = 'q',
        insert = '<C-c>',
      },
      reset = {
        normal = '<C-l>',
        insert = '<C-l>',
      },
      submit_prompt = {
        normal = '<CR>',
        insert = '<C-s>',
      },
      toggle_sticky = {
        detail = 'Makes line under cursor sticky or deletes sticky line.',
        normal = 'gr',
      },
      accept_diff = {
        normal = '<C-y>',
        insert = '<C-y>',
      },
      jump_to_diff = {
        normal = 'gj',
      },
      quickfix_diffs = {
        normal = 'gq',
      },
      yank_diff = {
        normal = 'gy',
        register = '"',
      },
      show_diff = {
        normal = 'gd',
      },
      show_info = {
        normal = 'gi',
      },
      show_context = {
        normal = 'gc',
      },
      show_help = {
        normal = 'gh',
      },
    },
    prompts = {
        Explain = {
            prompt = "/COPILOT_EXPLAIN コードを日本語で説明してください",
            description = "コードの説明をお願いする",
        },
        Review = {
            prompt = '/COPILOT_REVIEW コードを日本語でレビューしてください。',
            description = "コードのレビューをお願いする",
        },
        Fix = {
            prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします。",
            description = "コードの修正をお願いする",
        },
        Optimize = {
            prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。説明は日本語でお願いします。",
            description = "コードの最適化をお願いする",
        },
        Docs = {
            prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントコメントを日本語で生成してください。",
            description = "コードのドキュメント作成をお願いする",
        },
        Tests = {
            prompt = "/COPILOT_TESTS 選択したコードの詳細なユニットテストを書いてください。説明は日本語でお願いします。",
            description = "テストコード作成をお願いする",
        },
        FixDiagnostic = {
            prompt = 'コードの診断結果に従って問題を修正してください。修正内容の説明は日本語でお願いします。',
            description = "コードの修正をお願いする",
            selection = require('CopilotChat.select').diagnostics,
        },
        Commit = {
            prompt =
            '実装差分に対するコミットメッセージを日本語で記述してください。',
            description = "コミットメッセージの作成をお願いする",
            selection = require('CopilotChat.select').gitdiff,
        },
        CommitStaged = {
            prompt =
            'ステージ済みの変更に対するコミットメッセージを日本語で記述してください。',
            description = "ステージ済みのコミットメッセージの作成をお願いする",
            selection = function(source)
                return require('CopilotChat.select').gitdiff(source, true)
            end,
        },
     },
})

-- CopilotChat のコマンドを追加
vim.api.nvim_create_user_command("Reset", 
function()
   vim.cmd("CopilotChatReset")
end, {range = true})

vim.api.nvim_create_user_command("Fix", 
function()
   vim.cmd("CopilotChatFix")
end, {range = true})

vim.api.nvim_create_user_command("TestCase",
function()
   vim.cmd("CopilotChatTests")
end, {range = true})

vim.api.nvim_create_user_command("Commit",
function()
   vim.cmd("CopilotChatCommit")
end, {range = true})

vim.api.nvim_create_user_command("Refactor",
function()
   vim.cmd("CopilotChatOptimize")
end, {range = true})

vim.api.nvim_create_user_command("Ex",
function()
   vim.cmd("CopilotChatExplain")
end, {range = true})

vim.api.nvim_create_user_command("Chat",
function()
   vim.cmd("CopilotChat")
end, {range = true})


