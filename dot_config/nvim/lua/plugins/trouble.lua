return {
  'folke/trouble.nvim',
  cmd = { 'Trouble' },
  opts = {
    -- ========================================================================
    -- GENERAL SETTINGS
    -- ========================================================================
    auto_close = false, -- Auto close when there are no items
    auto_open = false, -- Auto open when there are items
    auto_preview = true, -- Auto preview the item under cursor
    auto_refresh = true, -- Auto refresh when open
    auto_jump = false, -- Auto jump to the item under cursor
    focus = true, -- Focus trouble window when opened
    restore = true, -- Restore window position when reopened
    follow = true, -- Follow current item
    indent_guides = true, -- Show indent guides
    max_items = 200, -- Maximum number of items
    multiline = true, -- Render multiline messages
    pinned = false, -- Pin trouble window
    warn_no_results = true, -- Show warning when no results
    open_no_results = false, -- Open when no results

    -- ========================================================================
    -- WINDOW CONFIGURATION
    -- ========================================================================
    win = {
      type = 'split',
      position = 'bottom',
      size = { height = 0.3 }, -- 30% of screen height
      border = 'rounded',
      padding = { top = 0, bottom = 0, left = 1, right = 1 },
      title = ' Trouble ',
      title_pos = 'center',
      zindex = 200,
    },

    -- ========================================================================
    -- PREVIEW WINDOW
    -- ========================================================================
    preview = {
      type = 'main',
      scratch = true,
      wo = {
        wrap = true,
        signcolumn = 'no',
      },
    },

    -- ========================================================================
    -- MODES CONFIGURATION
    -- ========================================================================
    modes = {
      -- Diagnostics mode - show all diagnostics
      diagnostics = {
        mode = 'diagnostics',
        preview = {
          type = 'split',
          relative = 'win',
          position = 'right',
          size = 0.4,
        },
        groups = {
          { 'filename', format = '{file_icon} {basename:Title} {count}' },
        },
        format = '{severity_icon} {message:md}',
        sort = { 'severity', 'filename', 'pos' },
        filter = {
          any = {
            buf = 0, -- Current buffer
            {
              severity = vim.diagnostic.severity.ERROR,
              severity = vim.diagnostic.severity.WARN,
            },
          },
        },
      },

      -- LSP mode - references, definitions, etc.
      lsp = {
        mode = 'lsp',
        win = {
          position = 'right',
          size = 0.4,
        },
        preview = {
          type = 'main',
          scratch = true,
        },
        groups = {
          { 'filename', format = '{file_icon} {basename:Title} {count}' },
        },
        format = '{kind_icon} {symbol.name} {pos}',
        sort = { 'pos' },
      },

      -- Document symbols
      symbols = {
        mode = 'lsp_document_symbols',
        win = {
          position = 'right',
          size = 0.3,
        },
        focus = true,
        groups = {},
        format = '{kind_icon} {symbol.name}',
        sort = { 'pos' },
        filter = {
          any = {
            ft = { 'help', 'markdown' },
            kind = {
              'Class',
              'Constructor',
              'Enum',
              'Function',
              'Interface',
              'Method',
              'Module',
              'Struct',
            },
          },
        },
      },

      -- Quickfix list
      qflist = {
        mode = 'qflist',
        groups = {
          { 'filename', format = '{file_icon} {basename:Title} {count}' },
        },
        format = '{text}',
      },

      -- Location list
      loclist = {
        mode = 'loclist',
        groups = {
          { 'filename', format = '{file_icon} {basename:Title} {count}' },
        },
        format = '{text}',
      },

      -- Todo comments (requires todo-comments.nvim)
      todo = {
        mode = 'todo',
        groups = {
          { 'filename', format = '{file_icon} {basename:Title} {count}' },
        },
        format = '{tag} {text:md}',
        sort = { 'pos' },
      },
    },

    -- ========================================================================
    -- ICONS
    -- ========================================================================
    icons = {
      indent = {
        top = '│ ',
        middle = '├╴',
        last = '└╴',
        fold_open = ' ',
        fold_closed = ' ',
        ws = '  ',
      },
      folder_closed = ' ',
      folder_open = ' ',
      kinds = {
        Array = ' ',
        Boolean = '󰨙 ',
        Class = ' ',
        Constant = '󰏿 ',
        Constructor = ' ',
        Enum = ' ',
        EnumMember = ' ',
        Event = ' ',
        Field = ' ',
        File = ' ',
        Function = '󰊕 ',
        Interface = ' ',
        Key = ' ',
        Method = '󰊕 ',
        Module = ' ',
        Namespace = '󰦮 ',
        Null = ' ',
        Number = '󰎠 ',
        Object = ' ',
        Operator = ' ',
        Package = ' ',
        Property = ' ',
        String = ' ',
        Struct = '󰆼 ',
        TypeParameter = ' ',
        Variable = '󰀫 ',
      },
    },
  },

  -- ==========================================================================
  -- KEYBINDINGS
  -- ==========================================================================
  keys = {
    -- ========================================================================
    -- DIAGNOSTICS
    -- ========================================================================
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>xe',
      '<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>',
      desc = 'Errors Only (Trouble)',
    },
    {
      '<leader>xw',
      '<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.WARN<cr>',
      desc = 'Warnings Only (Trouble)',
    },

    -- ========================================================================
    -- LSP
    -- ========================================================================
    {
      '<leader>cs',
      '<cmd>Trouble symbols toggle<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>cS',
      '<cmd>Trouble lsp toggle<cr>',
      desc = 'LSP references/definitions (Trouble)',
    },
    -- NOTE: gr, gd, gI kept with Telescope (configured in nvim-lspconfig.lua)
    -- To use Trouble for LSP, uncomment these and remove Telescope mappings:
    -- {
    --   "gr",
    --   "<cmd>Trouble lsp_references toggle<cr>",
    --   desc = "LSP References (Trouble)",
    -- },
    -- {
    --   "gd",
    --   "<cmd>Trouble lsp_definitions toggle<cr>",
    --   desc = "LSP Definitions (Trouble)",
    -- },
    -- {
    --   "gI",
    --   "<cmd>Trouble lsp_implementations toggle<cr>",
    --   desc = "LSP Implementations (Trouble)",
    -- },
    {
      '<leader>ldt',
      '<cmd>Trouble lsp_type_definitions toggle<cr>',
      desc = 'Type Definitions (Trouble)',
    },

    -- ========================================================================
    -- LISTS
    -- ========================================================================
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },

    -- ========================================================================
    -- TODO COMMENTS
    -- ========================================================================
    {
      '<leader>xt',
      '<cmd>Trouble todo toggle<cr>',
      desc = 'Todo (Trouble)',
    },
    {
      '<leader>xT',
      '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>',
      desc = 'Todo/Fix/Fixme (Trouble)',
    },

    -- ========================================================================
    -- NAVIGATION
    -- ========================================================================
    -- Smart navigation - works with Trouble when open, otherwise uses vim cmds
    {
      '[q',
      function()
        if require('trouble').is_open() then
          require('trouble').prev { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Previous Trouble/Quickfix Item',
    },
    {
      ']q',
      function()
        if require('trouble').is_open() then
          require('trouble').next { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Next Trouble/Quickfix Item',
    },
  },
}

