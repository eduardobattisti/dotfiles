return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = function()
    require('which-key').setup({
      window = {
        border = 'rounded',
        position = 'bottom',
        margin = { 1, 0, 1, 0 },
        padding = { 2, 2, 2, 2 },
      },
    })

    -- Document key groups for better navigation
    require('which-key').register {
      ['<leader>b'] = { name = '[B]uffer', _ = 'which_key_ignore' },
      ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
      ['<leader>d'] = { name = '[D]iagnostic', _ = 'which_key_ignore' },
      ['<leader>f'] = { name = '[F]ind (Telescope)', _ = 'which_key_ignore' },
      ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
      ['<leader>l'] = { name = '[L]SP', _ = 'which_key_ignore' },
      ['<leader>m'] = { name = '[M]ark', _ = 'which_key_ignore' },
      ['<leader>n'] = { name = '[N]otifications', _ = 'which_key_ignore' },
      ['<leader>p'] = { name = '[P]rofiler', _ = 'which_key_ignore' },
      ['<leader>q'] = { name = '[Q]uit/Quickfix', _ = 'which_key_ignore' },
      ['<leader>r'] = { name = '[R]egister', _ = 'which_key_ignore' },
      ['<leader>s'] = { name = '[S]ubstitute/Search', _ = 'which_key_ignore' },
      ['<leader>t'] = { name = '[T]oggle/Terminal', _ = 'which_key_ignore' },
      ['<leader>u'] = { name = '[U]tilities/UI', _ = 'which_key_ignore' },
      ['<leader>w'] = { name = '[W]indow', _ = 'which_key_ignore' },
      ['<leader>x'] = { name = 'Diagnostics/Lists', _ = 'which_key_ignore' },
      ['<leader>z'] = { name = 'Fold/Zen', _ = 'which_key_ignore' },
      ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
      ['<leader><tab>'] = { name = 'Tabs', _ = 'which_key_ignore' },
    }
    -- Visual mode groups
    require('which-key').register({
      ['<leader>h'] = { 'Git [H]unk' },
      ['<leader>r'] = { '[R]egister' },
      ['<leader>s'] = { '[S]ubstitute' },
    }, { mode = 'v' })
  end,
}