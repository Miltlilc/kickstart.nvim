local M = {}

local config = require 'modules.config' 

function M.highlightOnYank()
    vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Highlight when yanking (copying) text',
        group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
        callback = function()
            vim.highlight.on_yank()
        end,
    })
end

function M.jdtls()
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function()
            require('jdtls').start_or_attach(config.jdtls())
            require('spring_boot').setup(config.spring_boot())
        end,
    })
end

return M
