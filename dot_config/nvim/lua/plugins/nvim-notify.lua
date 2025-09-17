return {
  'rcarriga/nvim-notify',
  opts = {
    top_down = false,
    render = 'wrapped-compact',
    stages = 'fade_in_slide_out',
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { border = 'rounded' })
    end,
  },
  keys = {
    { '<Esc>', function() require('notify').dismiss() end, desc = 'Dissmiss notifications' }
  },
  config = function(_, opts)
    local notify = require 'notify'
    notify.setup(opts)

    vim.notify = notify
  end,
}