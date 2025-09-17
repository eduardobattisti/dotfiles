return {
  'brenoprata10/nvim-highlight-colors',
  config = function()
    require('nvim-highlight-colors').setup {
      -- Render style
      -- 'background' | 'foreground' | 'virtual'
      render = 'background',

      -- Set virtual symbol (requires render to be set to 'virtual')
      virtual_symbol = '■',

      -- Highlight named colors, e.g. 'green'
      enable_named_colors = true,

      -- Highlight tailwind colors, e.g. 'bg-blue-500'
      enable_tailwind = true,

      -- Exclude filetypes
      exclude_filetypes = {},
      -- Exclude buftypes
      exclude_buftypes = {}
    }
  end,
}