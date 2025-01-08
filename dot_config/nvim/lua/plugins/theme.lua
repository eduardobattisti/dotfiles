return {
  'sainnhe/gruvbox-material',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark' -- or "light" for a light variant
    vim.cmd 'colorscheme gruvbox-material'
  end,
}
