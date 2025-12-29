return {
  'akinsho/toggleterm.nvim',
  enabled = false, -- Replaced by Snacks.nvim terminal
  version = '*',
  opts = {
    direction = 'float',
    size = 10,
    highlights = {
      Normal = { link = 'Normal' },
      NormalNC = { link = 'NormalNC' },
      NormalFloat = { link = 'NormalFloat' },
      FloatBorder = { link = 'FloatBorder' },
      StatusLine = { link = 'StatusLine' },
      StatusLineNC = { link = 'StatusLineNC' },
      WinBar = { link = 'WinBar' },
      WinBarNC = { link = 'WinBarNC' },
    },
    float_opts = {
      border = 'rounded',
    },
  },
  keys = {
    { '<Leader>tf', '<Cmd>ToggleTerm direction=float<CR>', desc = 'ToggleTerm float' },
    { '<Leader>th', '<Cmd>ToggleTerm size=10 direction=horizontal<CR>', desc = 'ToggleTerm horizontal' },
    { '<Leader>tv', '<Cmd>ToggleTerm size=80 direction=vertical<CR>', desc = 'ToggleTerm vertical' },
    { '<F7>', '<Cmd>execute v:count . "ToggleTerm"<CR>', desc = 'Toggle terminal' },
    { '<F7>', '<Cmd>ToggleTerm<CR>', mode = 't', desc = 'Toggle terminal' },
    { '<F7>', '<Esc><Cmd>ToggleTerm<CR>', mode = 'i', desc = 'Toggle terminl' },
  },
}
