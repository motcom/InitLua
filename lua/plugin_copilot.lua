-- CopilotChatの設定
require("CopilotChat").setup({
    show_help = "yes",
    chat_autocomplete = true,
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
    },
    prompts = {
        Explain = {
            prompt = "/COPILOT_EXPLAIN コードを日本語で説明してください",
            description = "コードの説明をお願いする",
        },
        Fix = {
            prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします。",
            description = "コードの修正をお願いする",
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
        -- 新しい翻訳プロンプト
       TranslateClipboard = {
           prompt = "次の内容を日本語に翻訳してください:",
           description = "クリップボードの内容を翻訳する",
           context = require('CopilotChat.context').register("+"),
           
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
   vim.cmd("CopilotChatFixDiagnostic")
end, {range = true})

vim.api.nvim_create_user_command("TestCase",
function()
   vim.cmd("CopilotChatTests")
end, {range = true})

vim.api.nvim_create_user_command("CommitStaged",
function()
   vim.cmd("CopilotChatCommit")
end, {range = true})

vim.api.nvim_create_user_command("Ex",
function()
   vim.cmd("CopilotChatExplain")
end, {range = true})

vim.api.nvim_create_user_command("Chat",
function()
   vim.cmd("CopilotChat")
end, {range = true})

vim.api.nvim_create_user_command("Tr",
function()
    vim.cmd("CopilotChatTranslateClipboard")
end, {range=true})

