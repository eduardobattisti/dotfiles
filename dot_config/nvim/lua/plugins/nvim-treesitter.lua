return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    opts = function(_, opts)
      opts.ensure_installed = {
        'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'vim', 'vimdoc',
        -- Frontend & web
        'javascript', 'typescript', 'tsx', 'json', 'yaml', 'css', 'scss', 'html', 'vue', 'graphql', 'dockerfile',
        -- Backend
        'php', 'go',
      }
      opts.auto_install = true
      opts.highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      }
      opts.indent = { enable = true, disable = { 'ruby' } }
      opts.textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = { query = '@function.outer', desc = 'Select around function' },
            ['if'] = { query = '@function.inner', desc = 'Select inside function' },
            ['ac'] = { query = '@class.outer', desc = 'Select around class' },
            ['ic'] = { query = '@class.inner', desc = 'Select inside class' },
            ['aa'] = { query = '@parameter.outer', desc = 'Select around argument' },
            ['ia'] = { query = '@parameter.inner', desc = 'Select inside argument' },
            ['ai'] = { query = '@conditional.outer', desc = 'Select around conditional' },
            ['ii'] = { query = '@conditional.inner', desc = 'Select inside conditional' },
            ['al'] = { query = '@loop.outer', desc = 'Select around loop' },
            ['il'] = { query = '@loop.inner', desc = 'Select inside loop' },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = { query = '@function.outer', desc = 'Next function start' },
            [']c'] = { query = '@class.outer', desc = 'Next class start' },
            [']a'] = { query = '@parameter.inner', desc = 'Next argument' },
          },
          goto_next_end = {
            [']F'] = { query = '@function.outer', desc = 'Next function end' },
            [']C'] = { query = '@class.outer', desc = 'Next class end' },
          },
          goto_previous_start = {
            ['[f'] = { query = '@function.outer', desc = 'Previous function start' },
            ['[c'] = { query = '@class.outer', desc = 'Previous class start' },
            ['[a'] = { query = '@parameter.inner', desc = 'Previous argument' },
          },
          goto_previous_end = {
            ['[F'] = { query = '@function.outer', desc = 'Previous function end' },
            ['[C'] = { query = '@class.outer', desc = 'Previous class end' },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>csa'] = { query = '@parameter.inner', desc = 'Swap with next argument' },
          },
          swap_previous = {
            ['<leader>csA'] = { query = '@parameter.inner', desc = 'Swap with previous argument' },
          },
        },
      }
    end,
    config = function(_, opts)
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

      parser_config.blade = {
        install_info = {
          url = 'https://github.com/EmranMR/tree-sitter-blade',
          files = { 'src/parser.c' },
          branch = 'main',
        },
        filetype = 'blade',
      }

      vim.filetype.add {
        extension = {
          stylus = 'css',
          postcss = 'sass',
          pcss = 'sass',
        },
        pattern = {
          ['.*%.blade%.php'] = 'blade',
        },
      }

      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
