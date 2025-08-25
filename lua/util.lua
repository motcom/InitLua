local M = {}


function M.find_project_root()
    local markers = {".git", "pyproject.toml", "setup.py", "main.py" }
    local dir = vim.fn.getcwd()
    local dir_tmp = vim.fn.fnamemodify(dir, ":p")
    local drive = string.sub(dir_tmp, 1, 3)
     print(drive)

    while dir ~= drive do
        for _, marker in ipairs(markers) do
            if vim.fn.glob(dir .. "/" .. marker) ~= "" then
                return dir
            end
        end
        dir = vim.fn.fnamemodify(dir, ":h")
        print(dir)
    end
    return nil
end


function M.RunInTerminal(cmd)
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("terminal")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("A", true, true, true), "n", false)
    vim.schedule(function()
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\r")
  end)
end

return M
