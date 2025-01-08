return {
  'stevearc/resession.nvim',
  opts = {
    autosave = {
      enabled = true,
      interval = 60,
      notify = true,
    },
  },
  config = function(_, opts)
    local resession = require 'resession'
    resession.setup(opts)

    vim.keymap.set('n', '<leader>Ss', resession.save, { desc = 'Save the current session' })
    vim.keymap.set('n', '<leader>Sl', resession.load, { desc = 'Load a session' })
    vim.keymap.set('n', '<leader>Sd', resession.delete, { desc = 'Delete a session' })

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        resession.save 'last'
      end,
    })
  end,
}
