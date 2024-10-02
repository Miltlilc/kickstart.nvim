function keymap(keys, func, desc, mode, buf)
    vim.keymap.set(mode or { 'n' }, keys, func, { buffer = buf or 0, desc = desc })
end

local M = {}

function M.init()
    keymap('<Esc>', '<cmd>nohlsearch<CR>', 'Drop highlight')

    keymap('[d', vim.diagnostic.goto_prev, 'Go to previous [D]iagnostic message')
    keymap(']d', vim.diagnostic.goto_next, 'Go to next [D]iagnostic message')
    keymap('<leader>qf', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')

    keymap('<leader>e', '<cmd>Ex<CR>', 'Open netwr file explorer')
    keymap('<Esc><Esc>', '<C-\\><C-n>', 'Exit terminal mode', 't')

    keymap('<C-h>', '<C-w><C-h>', 'Move focus to the left window')
    keymap('<C-l>', '<C-w><C-l>', 'Move focus to the right window')
    keymap('<C-j>', '<C-w><C-j>', 'Move focus to the lower window')
    keymap('<C-k>', '<C-w><C-k>', 'Move focus to the upper window')

    vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
    keymap('<leader>f', '<Plug>(leap)', 'Leap.nvim leap action', 'n')

    keymap('va<leader>', function()
        require('leap.treesitter').select()
    end, 'Leap.nvim treesitter action', { 'n', 'x', 'o' })

    keymap('<leader>F', function()
        require('conform').format { async = true, lsp_format = 'first' }
    end, '[F]ormat buffer')
end

return M
