return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    signs = {
      add          = { text = '│' },
      change       = { text = '│' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      follow_files = true
    },
    auto_attach = true,
    attach_to_untracked = false,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = {
      -- Options passed to nvim_open_win
      border = 'single',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1
    },
  },
  config = function(_, opts)
    require('gitsigns').setup(opts)
    
    -- Enhanced git keymaps (replaces git-blame functionality)
    vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<cr>', { desc = '[G]it [B]lame toggle' })
    vim.keymap.set('n', '<leader>gB', '<cmd>Gitsigns blame_line{full=true}<cr>', { desc = '[G]it [B]lame full' })
    vim.keymap.set('n', '<leader>hd', '<cmd>Gitsigns diffthis<cr>', { desc = 'Git [H]unk [D]iff' })
    vim.keymap.set('n', '<leader>hD', function() require('gitsigns').diffthis('~') end, { desc = 'Git [H]unk [D]iff against HEAD' })
    vim.keymap.set('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<cr>', { desc = 'Git [H]unk [P]review' })
    vim.keymap.set('n', '<leader>hr', '<cmd>Gitsigns reset_hunk<cr>', { desc = 'Git [H]unk [R]eset' })
    vim.keymap.set('v', '<leader>hr', function() require('gitsigns').reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Git [H]unk [R]eset' })
    vim.keymap.set('n', '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', { desc = 'Git [H]unk [S]tage' })
    vim.keymap.set('v', '<leader>hs', function() require('gitsigns').stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Git [H]unk [S]tage' })
    vim.keymap.set('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<cr>', { desc = 'Git [H]unk [U]ndo stage' })
    
    -- Navigation
    vim.keymap.set('n', ']h', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() require('gitsigns').next_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = 'Next git hunk' })
    
    vim.keymap.set('n', '[h', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() require('gitsigns').prev_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = 'Previous git hunk' })
  end,
}
