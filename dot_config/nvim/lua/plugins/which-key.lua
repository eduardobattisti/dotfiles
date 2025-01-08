return { -- Useful plugin to show you pending keybinds. 'folke/which-key.nvim',
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  opts = {
    win = {
      title = false,
      border = 'rounded',
    },
  },
  config = function(_, opts) -- This is the function that runs, AFTER loading
    require('which-key').setup(opts)

    -- Document existing key chains
    require('which-key').add {
      { '<leader>l', group = '[L]sp', icon = '󰈔' },
      { '<leader>d', group = '[D]ebug', icon = '' },
      { '<leader>s', group = '[S]urround', icon = '󱃗' },
      { '<leader>S', group = '[S]ession', icon = '' },
      { '<leader>f', group = '[F]ind', icon = '󰭎' },
      { '<leader>t', group = '[T]erminal', icon = '' },
      { '<leader>g', group = '[G]it', icon = '' },
      { '<leader>c', group = '[C]onfig', icon = '' },
    }
  end,
}
