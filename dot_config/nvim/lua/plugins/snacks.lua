return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = {
      enabled = true,
      size = 1024 * 1024,
      setup = function(ctx)
        vim.cmd [[NoMatchParen]]
        vim.opt_local.foldmethod = 'manual'
        vim.opt_local.spell = false
        vim.schedule(function()
          vim.bo[ctx.buf].syntax = ''
        end)
      end,
    },

    notifier = {
      enabled = true,
      timeout = 3000, -- Default timeout in ms
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { 'level', 'added' },
      level = vim.log.levels.INFO,
      icons = {
        error = ' ',
        warn = ' ',
        info = ' ',
        debug = ' ',
        trace = ' ',
      },
      style = 'compact',
    },

    quickfile = {
      enabled = true,
    },

    statuscolumn = {
      enabled = true,
      left = { 'mark', 'sign' },
      right = { 'fold', 'git' },
      folds = {
        open = false, -- show open fold icons
        git_hl = false, -- use Git Signs hl for fold icons
      },
      git = {
        patterns = { 'GitSign', 'MiniDiffSign' },
      },
      refresh = 50, -- refresh at most every 50ms
    },

    words = {
      enabled = true,
      debounce = 200,
      notify_jump = false,
      notify_end = true,
      foldopen = true,
      jumplist = true,
      modes = { 'n' },
    },

    styles = {
      notification = {
        wo = { wrap = true },
        border = 'rounded',
      },
      notification_history = {
        border = 'rounded',
        zindex = 100,
        bo = {
          buftype = '',
          modifiable = true,
          readonly = false,
        },
        wo = {
          cursorline = true,
        },
      },
    },

    dashboard = {
      enabled = true,
    },

    indent = {
      enabled = true,
    },

    scroll = {
      enabled = true,
    },

    animate = {
      enabled = false,
    },
  },

  keys = {
    -- ========================================================================
    -- BUFFER MANAGEMENT
    -- ========================================================================
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete Buffer',
    },
    {
      '<leader>bo',
      function()
        Snacks.bufdelete.other()
      end,
      desc = 'Delete Other Buffers',
    },
    {
      '<leader>bD',
      '<cmd>:bd<cr>',
      desc = 'Delete Buffer and Window',
    },

    -- ========================================================================
    -- GIT INTEGRATION
    -- ========================================================================
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit (Root Dir)',
    },
    {
      '<leader>gG',
      function()
        Snacks.lazygit { cwd = vim.fn.getcwd() }
      end,
      desc = 'Lazygit (cwd)',
    },
    {
      '<leader>gb',
      function()
        Snacks.git.blame_line()
      end,
      desc = 'Git Blame Line',
    },
    {
      '<leader>gB',
      function()
        Snacks.gitbrowse()
      end,
      mode = { 'n', 'x' },
      desc = 'Git Browse (open)',
    },
    {
      '<leader>gY',
      function()
        Snacks.gitbrowse {
          open = function(url)
            vim.fn.setreg('+', url)
          end,
          notify = false,
        }
      end,
      mode = { 'n', 'x' },
      desc = 'Git Browse (copy URL)',
    },

    -- ========================================================================
    -- TERMINAL
    -- ========================================================================
    {
      '<leader>ft',
      function()
        Snacks.terminal()
      end,
      desc = 'Terminal (Root Dir)',
    },
    {
      '<leader>fT',
      function()
        Snacks.terminal(nil, { cwd = vim.fn.getcwd() })
      end,
      desc = 'Terminal (cwd)',
    },
    {
      '<c-/>',
      function()
        Snacks.terminal()
      end,
      desc = 'Terminal (Root Dir)',
      mode = { 'n', 't' },
    },
    {
      '<c-_>', -- For terminals that send <C-_> instead of <C-/>
      function()
        Snacks.terminal()
      end,
      desc = 'which_key_ignore',
      mode = { 'n', 't' },
    },

    -- ========================================================================
    -- WORD REFERENCES
    -- ========================================================================
    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference',
      mode = { 'n', 't' },
    },
    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference',
      mode = { 'n', 't' },
    },

    -- ========================================================================
    -- NOTIFICATIONS
    -- ========================================================================
    {
      '<leader>un',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<leader>nh',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>nD',
      function()
        local notifier = require 'snacks.notifier'
        local history = notifier.history or {}

        local file = io.open('/tmp/nvim-notifications.txt', 'w')
        if not file then
          vim.notify('Failed to open file for writing', vim.log.levels.ERROR)
          return
        end

        file:write '=== NEOVIM NOTIFICATION HISTORY ===\n'
        file:write('Generated: ' .. os.date '%Y-%m-%d %H:%M:%S' .. '\n\n')

        for i = #history, 1, -1 do
          local notif = history[i]
          local level = vim.log.levels[notif.level] or 'INFO'
          local time = os.date('%Y-%m-%d %H:%M:%S', notif.added or 0)

          file:write(string.format('[%s] %s\n', time, level))

          if type(notif.msg) == 'string' then
            file:write(notif.msg .. '\n')
          elseif type(notif.msg) == 'table' then
            file:write(vim.inspect(notif.msg) .. '\n')
          else
            file:write(tostring(notif.msg) .. '\n')
          end

          if notif.title then
            file:write('Title: ' .. notif.title .. '\n')
          end

          file:write('\n' .. string.rep('-', 80) .. '\n\n')
        end

        file:close()
        vim.notify('Notifications dumped to /tmp/nvim-notifications.txt', vim.log.levels.INFO)
        vim.cmd 'edit /tmp/nvim-notifications.txt'
      end,
      desc = 'Dump Notifications to File',
    },

    {
      '<leader>ps',
      function()
        Snacks.profiler.scratch()
      end,
      desc = 'Profiler Scratch',
    },

    -- ========================================================================
    -- RENAME FILE
    -- ========================================================================
    {
      '<leader>cR',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'Rename File',
    },

    -- ========================================================================
    -- ZEN MODE
    -- ========================================================================
    {
      '<leader>z',
      function()
        Snacks.zen()
      end,
      desc = 'Toggle Zen Mode',
    },
    {
      '<leader>Z',
      function()
        Snacks.zen.zoom()
      end,
      desc = 'Toggle Zoom',
    },
  },

  -- ==========================================================================
  -- INITIALIZATION
  -- ==========================================================================
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd

        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
        Snacks.toggle.diagnostics():map '<leader>ud'
        Snacks.toggle.line_number():map '<leader>ul'
        Snacks.toggle
          .option('conceallevel', {
            off = 0,
            on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
            name = 'Conceal Level',
          })
          :map '<leader>uc'
        Snacks.toggle.treesitter():map '<leader>uT'
        Snacks.toggle
          .option('background', {
            off = 'light',
            on = 'dark',
            name = 'Dark Background',
          })
          :map '<leader>ub'

        if vim.lsp.inlay_hint then
          Snacks.toggle.inlay_hints():map '<leader>uh'
        end
      end,
    })
  end,
}
