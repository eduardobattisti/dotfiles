return {
  'mrjones2014/smart-splits.nvim',
  opts = {},
  config = function(_, opts)
    local smart_splits = require 'smart-splits'
    vim.keymap.set('n', '<A-h>', smart_splits.resize_left, { desc = 'Resize buffer left' })
    vim.keymap.set('n', '<A-j>', smart_splits.resize_down, { desc = 'Resize buffer down' })
    vim.keymap.set('n', '<A-k>', smart_splits.resize_up, { desc = 'Resize buffer up' })
    vim.keymap.set('n', '<A-l>', smart_splits.resize_right, { desc = 'Resize buffer right' })

    return opts
  end,
}
