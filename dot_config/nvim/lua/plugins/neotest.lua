return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-jest',
    'olimorris/neotest-phpunit',
  },

  config = function()
    require('neotest').setup {
      adapters = {
        require('neotest-jest') {
          jestCommand = 'npm test --',
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
        require 'neotest-phpunit',
      },
    }
  end,

  keys = {
    { '<leader>Tt', function() require('neotest').run.run() end, desc = 'Run Nearest Test' },
    { '<leader>Tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run Test File' },
    { '<leader>Ts', function() require('neotest').summary.toggle() end, desc = 'Toggle Test Summary' },
    { '<leader>To', function() require('neotest').output.open({ enter = true }) end, desc = 'Test Output' },
  },
}