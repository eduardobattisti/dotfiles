return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
  },

  setup = function(_, opts)
    opts.adapters = {
      require 'neotest-jest' {
        jestCommand = 'npm test --',
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      },
    }

    require('neotest').setup(opts)
  end,
}
