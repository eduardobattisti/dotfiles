return {
  'stevearc/resession.nvim',
  opts = {
    autosave = {
      enabled = true,
      interval = 60,
      notify = true,
    },
  },
  keys = {
    { '<leader>Ss', function() require('resession').save() end, desc = 'Save the current session' },
    { '<leader>Sl', function() require('resession').load() end, desc = 'Load a session' },
    { '<leader>Sd', function() require('resession').delete() end, desc = 'Delete a session' },
  },
  config = function(_, opts)
    local resession = require 'resession'
    resession.setup(opts)

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        resession.save 'last'
      end,
    })
  end,
}
