return {
  'mistweaverco/kulala.nvim',
  ft = { 'http', 'rest' },
  opts = {},
  keys = {
    { '<leader>Rs', function() require('kulala').run() end, ft = { 'http', 'rest' }, desc = '[R]est Send Request' },
    { '<leader>Rp', function() require('kulala').jump_prev() end, ft = { 'http', 'rest' }, desc = '[R]est Prev Request' },
    { '<leader>Rn', function() require('kulala').jump_next() end, ft = { 'http', 'rest' }, desc = '[R]est Next Request' },
    { '<leader>Ri', function() require('kulala').inspect() end, ft = { 'http', 'rest' }, desc = '[R]est Inspect' },
  },
}
