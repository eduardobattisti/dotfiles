return {
  'neanias/everforest-nvim',
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    local everforest = require 'everforest'

    everforest.setup {
      background = 'medium',
      transparent_background_level = 0,
      italics = true,
      disable_italic_comments = false,
    }

    everforest.load()
  end,
}
