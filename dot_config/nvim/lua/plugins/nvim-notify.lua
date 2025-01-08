return {
  'rcarriga/nvim-notify',
  opts = {},
  config = function(_, opts)
    local notify = require 'notify'
    notify.setup(opts)

    vim.notify = notify
  end,
}
