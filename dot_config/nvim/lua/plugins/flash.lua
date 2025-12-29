return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  ---@type Flash.Config
  opts = {
    -- Labels to use for jump targets
    labels = 'asdfghjklqwertyuiopzxcvbnm',

    -- Search options
    search = {
      -- Search mode: "exact", "search", "fuzzy"
      mode = 'exact',
      -- Behave like `incsearch`
      incremental = false,
      -- Use smartcase for search
      forward = true,
      wrap = true,
      multi_window = true,
    },

    -- Jump options
    jump = {
      -- Save location in jumplist
      jumplist = true,
      -- Jump position: "start", "end", "range"
      pos = 'start',
      -- Add pattern to search history
      history = false,
      -- Set to `true` to clear the search highlighting
      nohlsearch = false,
      -- Automatically jump when there's only one match
      autojump = false,
    },

    -- Label appearance
    label = {
      -- Allow uppercase labels
      uppercase = true,
      -- Add any number of labels per jump target
      rainbow = {
        enabled = false,
        shade = 5,
      },
    },

    -- Highlight settings
    highlight = {
      -- Show a backdrop with hl FlashBackdrop
      backdrop = true,
      -- Highlight matches
      matches = true,
      -- Extmark priority
      priority = 5000,
      groups = {
        match = 'FlashMatch',
        current = 'FlashCurrent',
        backdrop = 'FlashBackdrop',
        label = 'FlashLabel',
      },
    },

    -- Action to perform when picking a label
    action = nil,

    -- Initial pattern to search for
    pattern = '',

    -- When `true`, flash will be activated automatically when pressing these keys
    continue = false,

    -- Configuration for different modes
    modes = {
      -- Options for search-based flash
      search = {
        enabled = true,
        highlight = { backdrop = false },
        jump = { history = true, register = true, nohlsearch = true },
      },
      -- Options for character-based flash (f, t, F, T motions)
      char = {
        enabled = true,
        -- Enable for all directions by default
        keys = { 'f', 'F', 't', 'T', ';', ',' },
        search = { wrap = false },
        highlight = { backdrop = true },
        jump = { register = false },
        jump_labels = function(motion)
          -- Never show jump labels by default
          return false
        end,
      },
      -- Options for treesitter
      treesitter = {
        labels = 'abcdefghijklmnopqrstuvwxyz',
        jump = { pos = 'range' },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
      -- Remote operations (like 'y' followed by flash jump)
      remote = {
        remote_op = { restore = true, motion = true },
      },
    },
  },

  -- Keybindings
  keys = {
    -- ========================================================================
    -- PRIMARY NAVIGATION
    -- ========================================================================
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },

    -- ========================================================================
    -- TREESITTER SELECTION
    -- ========================================================================
    {
      'S',
      mode = { 'n', 'o', 'x' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },

    -- ========================================================================
    -- REMOTE OPERATIONS (operator pending)
    -- ========================================================================
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },

    -- ========================================================================
    -- TREESITTER SEARCH
    -- ========================================================================
    {
      'R',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Treesitter Search',
    },

    -- ========================================================================
    -- TOGGLE FLASH IN COMMAND MODE
    -- ========================================================================
    {
      '<c-s>',
      mode = { 'c' },
      function()
        require('flash').toggle()
      end,
      desc = 'Toggle Flash Search',
    },
  },
}

