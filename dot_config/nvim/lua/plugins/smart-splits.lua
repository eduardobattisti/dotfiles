return {
  'mrjones2014/smart-splits.nvim',
  opts = {},
  keys = {
    { '<C-A-h>', function() require('smart-splits').resize_left() end, desc = 'Resize buffer left', mode = 'n' },
    { '<C-A-j>', function() require('smart-splits').resize_down() end, desc = 'Resize buffer down', mode = 'n' },
    { '<C-A-k>', function() require('smart-splits').resize_up() end, desc = 'Resize buffer up', mode = 'n' },
    { '<C-A-l>', function() require('smart-splits').resize_right() end, desc = 'Resize buffer right', mode = 'n' },
  },
}