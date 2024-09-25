return {
  {
    'goolord/alpha-nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('alpha').setup(require('alpha.themes.theta').config)
    end,
  },
  {
    'pocco81/auto-save.nvim',
    opts = {
      execution_message = {
        message = function() -- message to print on save
          return 'Saved'
        end,

        dim = 0.7, -- dim the color of `message`
        cleaning_interval = 250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
      },
    },
  },
  {
    'ggandor/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
      vim.keymap.set({ 'n', 'x', 'o' }, '<leader>s', '<Plug>(leap)')
      vim.keymap.set({ 'n', 'x', 'o' }, '<leader>vs', function()
        require('leap.treesitter').select()
      end)
    end,
  },
}
