return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    -- Uses default keys: sa (add), sd (delete), sr (replace), sf (find), sF (find left), sh (highlight), sn (update n_lines)
    require('mini.surround').setup()

    -- Autopairs with edge-case handling (strings, comments, etc.)
    require('mini.pairs').setup()
  end,
}
