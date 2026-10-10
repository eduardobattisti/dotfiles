return {
  'mrjones2014/smart-splits.nvim',
  -- Moves between Neovim windows and, at an edge, into the neighbouring
  -- WezTerm pane. The IS_NVIM user var is set in config/autocmds.lua.
  opts = {},
  keys = {
    { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move to left window/pane', mode = 'n' },
    { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move to lower window/pane', mode = 'n' },
    { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move to upper window/pane', mode = 'n' },
    { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move to right window/pane', mode = 'n' },
    { '<C-A-h>', function() require('smart-splits').resize_left() end, desc = 'Resize buffer left', mode = 'n' },
    { '<C-A-j>', function() require('smart-splits').resize_down() end, desc = 'Resize buffer down', mode = 'n' },
    { '<C-A-k>', function() require('smart-splits').resize_up() end, desc = 'Resize buffer up', mode = 'n' },
    { '<C-A-l>', function() require('smart-splits').resize_right() end, desc = 'Resize buffer right', mode = 'n' },
  },
}
