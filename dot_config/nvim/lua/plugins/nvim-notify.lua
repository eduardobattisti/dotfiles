return {
  'rcarriga/nvim-notify',
  opts = {
    top_down = false,
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
