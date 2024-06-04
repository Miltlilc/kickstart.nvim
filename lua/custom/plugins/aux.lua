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
}
