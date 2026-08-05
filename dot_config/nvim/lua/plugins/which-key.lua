return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup({
      win = {
        border = 'rounded',
        padding = { 2, 2 },
      },
    })

    require('which-key').add {
      { '<leader>b', group = '[B]uffer' },
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]iagnostic' },
      { '<leader>f', group = '[F]ind (Telescope)' },
      { '<leader>g', group = '[G]it' },
      { '<leader>h', group = 'Git [H]unk' },
      { '<leader>l', group = '[L]SP' },
      { '<leader>L', group = '[L]aravel' },
      { '<leader>m', group = '[M]ark' },
      { '<leader>n', group = '[N]otifications' },
      { '<leader>o', group = '[O]verseer/Tasks' },
      { '<leader>p', group = '[P]rofiler' },
      { '<leader>q', group = '[Q]uit/Quickfix' },
      { '<leader>r', group = '[R]egister' },
      { '<leader>R', group = '[R]est (kulala)' },
      { '<leader>s', group = '[S]earch/Replace (grug-far)' },
      { '<leader>t', group = '[T]erminal/Test' },
      { '<leader>T', group = '[T]est (neotest)' },
      { '<leader>u', group = '[U]I Toggles' },
      { '<leader>v', group = '[V]ersion (npm)' },
      { '<leader>w', group = '[W]indow' },
      { '<leader>x', group = 'Diagnostics/Lists' },
      { '<leader>z', group = 'Fold/Zen' },
      { '<leader><tab>', group = 'Tabs' },
      -- Visual mode groups
      { '<leader>h', desc = 'Git [H]unk', mode = 'v' },
      { '<leader>r', desc = '[R]egister', mode = 'v' },
      { '<leader>s', desc = '[S]earch/Replace', mode = 'v' },
    }
  end,
}
