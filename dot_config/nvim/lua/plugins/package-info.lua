return {
  'vuki656/package-info.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  ft = 'json',
  opts = {},
  keys = {
    { '<leader>vs', function() require('package-info').show() end, desc = '[V]ersion Show' },
    { '<leader>vc', function() require('package-info').hide() end, desc = '[V]ersion Close' },
    { '<leader>vu', function() require('package-info').update() end, desc = '[V]ersion Update' },
    { '<leader>vd', function() require('package-info').delete() end, desc = '[V]ersion Delete' },
    { '<leader>vi', function() require('package-info').install() end, desc = '[V]ersion Install' },
    { '<leader>vp', function() require('package-info').change_version() end, desc = '[V]ersion Pick' },
  },
}
