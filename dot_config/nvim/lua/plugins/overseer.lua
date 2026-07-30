return {
  'stevearc/overseer.nvim',
  cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerQuickAction' },
  opts = {},
  keys = {
    { '<leader>oo', '<cmd>OverseerToggle<cr>', desc = '[O]verseer Toggle' },
    { '<leader>or', '<cmd>OverseerRun<cr>', desc = '[O]verseer Run (npm script)' },
    { '<leader>oa', '<cmd>OverseerQuickAction<cr>', desc = '[O]verseer Quick Action' },
  },
}
