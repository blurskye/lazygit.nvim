local M = {}

M.git_buf = nil
M.config = { -- Initialize M.config
    toggle_key = '<F8>',
}

function M.setup(config)
    if type(config) == 'table' then
        M.config = vim.tbl_extend('force', M.config, config)
    end

    vim.api.nvim_set_keymap('n', M.config.toggle_key, '<cmd>lua require("lazygit").toggle_git()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_set_keymap('t', M.config.toggle_key, '<cmd>lua require("lazygit").toggle_git()<CR>',
        { noremap = true, silent = true })
end

-- function M.toggle_git()
--     if vim.api.nvim_buf_get_name(0) == " LAZYGIT" then
--         vim.api.nvim_win_hide(M.git_win)
--         M.git_win = nil
--     elseif M.git_buf == nil or not vim.api.nvim_buf_is_valid(M.git_buf) then
--         M.git_buf = vim.api.nvim_create_buf(false, true)
--         M.git_win = vim.api.nvim_open_win(M.git_buf, true, {
--             relative = "editor",
--             width = vim.o.columns,
--             height = vim.o.lines - 1, -- Subtract 1 to leave space for the status line
--             col = 0,
--             row = 0,
--         })
--         vim.api.nvim_buf_set_option(M.git_buf, 'buftype', 'nofile')
--         vim.api.nvim_buf_set_option(M.git_buf, 'bufhidden', 'hide')
--         vim.fn.termopen("lazygit")

--         -- Set buffer name to "LAZYGIT"
--         vim.api.nvim_buf_set_name(M.git_buf, " LAZYGIT")

--         -- Hide line numbers in the git window
--         vim.api.nvim_win_set_option(M.git_win, 'number', false)
--         vim.api.nvim_win_set_option(M.git_win, 'relativenumber', false)
--     else
--         if M.git_win ~= nil and vim.api.nvim_win_is_valid(M.git_win) then
--             vim.api.nvim_win_hide(M.git_win)
--             M.git_win = nil
--         else
--             M.git_win = vim.api.nvim_open_win(M.git_buf, true, {
--                 relative = "editor",
--                 width = vim.o.columns,
--                 height = vim.o.lines - 1, -- Subtract 1 to leave space for the status line
--                 col = 0,
--                 row = 0,
--             })
--         end
--     end
--     vim.cmd('startinsert')
-- end

function M.lualine_component()
    if M.git_buf and vim.api.nvim_buf_is_valid(M.git_buf) then
        return ' Lazygit'
    else
        return ''
    end
end

function M.toggle_git()
    if M.git_buf and vim.api.nvim_buf_is_valid(M.git_buf) then
        -- If the git window is open, hide it
        if M.git_win and vim.api.nvim_win_is_valid(M.git_win) then
            vim.api.nvim_win_hide(M.git_win)
            M.git_win = nil
        else
            -- If the git window is not open, open it
            M.git_win = vim.api.nvim_open_win(M.git_buf, true, {
                relative = "editor",
                width = vim.o.columns,
                height = vim.o.lines - 1, -- Subtract 1 to leave space for the status line
                col = 0,
                row = 0,
            })
            vim.cmd('startinsert')
        end
    else
        -- If the git buffer does not exist or is not valid, create it
        local job_id = M.git_buf and vim.api.nvim_buf_is_valid(M.git_buf) and
            vim.fn.jobpid(vim.api.nvim_buf_get_option(M.git_buf, 'channel'))
        if M.git_buf == nil or not vim.api.nvim_buf_is_valid(M.git_buf) or (job_id and vim.fn.jobstop(job_id) ~= 0) then
            M.git_buf = vim.api.nvim_create_buf(false, true)
            M.git_win = vim.api.nvim_open_win(M.git_buf, true, {
                relative = "editor",
                width = vim.o.columns,
                height = vim.o.lines - 1, -- Subtract 1 to leave space for the status line
                col = 0,
                row = 0,
            })
            vim.api.nvim_buf_set_option(M.git_buf, 'buftype', 'nofile')
            vim.api.nvim_buf_set_option(M.git_buf, 'bufhidden', 'hide')
            -- Set the name of the buffer to "lazygit"
            vim.api.nvim_buf_set_name(M.git_buf, " lazygit")
            -- Get the directory of the current file
            local dir = vim.fn.expand('%:p:h')

            -- Open lazygit in the terminal in the directory of the current file and set a callback to close the buffer when the process exits
            vim.fn.termopen("cd " .. dir .. " && lazygit", {
                on_exit = function()
                    vim.api.nvim_buf_delete(M.git_buf, { force = true })
                    M.git_buf = nil
                    M.git_win = nil
                end
            })

            -- Hide line numbers in the git window
            vim.api.nvim_win_set_option(M.git_win, 'number', false)
            vim.api.nvim_win_set_option(M.git_win, 'relativenumber', false)
            vim.cmd('startinsert')
        end
    end
end

return M
