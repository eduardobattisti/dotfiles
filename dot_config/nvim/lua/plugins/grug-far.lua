return {
  'MagicDuck/grug-far.nvim',
  opts = {
    -- ========================================================================
    -- GENERAL SETTINGS
    -- ========================================================================
    -- Max width of header (filename) column
    headerMaxWidth = 80,

    -- Minimum number of chars for search
    minSearchChars = 2,

    -- Max number of parallel replacements
    maxWorkers = 4,

    -- Enable ripgrep arguments
    rgPath = 'rg',

    -- Additional ripgrep flags
    extraRgArgs = '',

    -- ========================================================================
    -- UI SETTINGS
    -- ========================================================================
    -- Window configuration
    windowCreationCommand = 'vsplit',

    -- Transient mode (close after operation)
    transient = false,

    -- ========================================================================
    -- SEARCH SETTINGS
    -- ========================================================================
    -- Search on the fly (as you type)
    searchOnInsertLeave = false,

    -- Debounce time in ms for search
    debounceMs = 300,

    -- Max number of search results
    maxSearchCharsInTitles = 30,

    -- Show line numbers in results
    showLineNumbers = true,

    -- Wrap lines in results
    wrap = true,

    -- Icons for results
    icons = {
      enabled = true,
      actionMessage = {
        search = ' ',
        replace = ' ',
        searchReplace = ' ',
      },
      searchInput = ' ',
      replaceInput = ' ',
      filesFilterInput = ' ',
      flagsInput = '󰮚 ',
      resultsStatusReady = ' ',
      resultsStatusError = ' ',
      resultsStatusSuccess = ' ',
      resultsActionMessage = ' ',
      resultsChangeIndicator = '┃',
      historyTitle = ' ',
    },

    -- ========================================================================
    -- KEYMAPS (within grug-far buffer)
    -- ========================================================================
    keymaps = {
      replace = { n = '<localleader>r' },
      qflist = { n = '<localleader>q' },
      syncLocations = { n = '<localleader>s' },
      syncLine = { n = '<localleader>l' },
      close = { n = '<localleader>c' },
      historyOpen = { n = '<localleader>t' },
      historyAdd = { n = '<localleader>a' },
      refresh = { n = '<localleader>f' },
      openLocation = { n = '<localleader>o' },
      gotoLocation = { n = '<enter>' },
      pickHistoryEntry = { n = '<enter>' },
      abort = { n = '<localleader>b' },
      help = { n = 'g?' },
    },

    -- ========================================================================
    -- RESULT RENDERING
    -- ========================================================================
    -- Highlight groups
    resultLocation = {
      -- Show results in split or float
      showNumberLabel = true,
    },

    -- Spinner frames for loading
    spinnerStates = {
      '⠋',
      '⠙',
      '⠹',
      '⠸',
      '⠼',
      '⠴',
      '⠦',
      '⠧',
      '⠇',
      '⠏',
    },
  },

  -- ==========================================================================
  -- COMMANDS
  -- ==========================================================================
  cmd = { 'GrugFar', 'GrugFarWithin' },

  -- ==========================================================================
  -- KEYBINDINGS
  -- ==========================================================================
  keys = {
    -- ========================================================================
    -- SEARCH AND REPLACE
    -- ========================================================================
    {
      '<leader>sr',
      function()
        local grug = require 'grug-far'
        local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
        grug.open {
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          },
        }
      end,
      mode = { 'n', 'x' },
      desc = 'Search and Replace',
    },

    -- ========================================================================
    -- SEARCH AND REPLACE IN CURRENT FILE
    -- ========================================================================
    {
      '<leader>sf',
      function()
        local grug = require 'grug-far'
        grug.open {
          transient = true,
          prefills = {
            paths = vim.fn.expand '%',
          },
        }
      end,
      mode = { 'n', 'x' },
      desc = 'Search/Replace in File',
    },

    -- ========================================================================
    -- SEARCH WORD UNDER CURSOR
    -- ========================================================================
    {
      '<leader>sw',
      function()
        local grug = require 'grug-far'
        local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
        local word = vim.fn.expand '<cword>'
        grug.open {
          transient = true,
          prefills = {
            search = word,
            filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          },
        }
      end,
      desc = 'Search/Replace Word',
    },

    -- ========================================================================
    -- SEARCH VISUAL SELECTION
    -- ========================================================================
    {
      '<leader>sv',
      function()
        local grug = require 'grug-far'
        local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
        grug.with_visual_selection {
          prefills = {
            filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          },
        }
      end,
      mode = { 'x' },
      desc = 'Search/Replace Selection',
    },

    -- ========================================================================
    -- SEARCH IN DIRECTORY
    -- ========================================================================
    {
      '<leader>sd',
      function()
        local grug = require 'grug-far'
        local path = vim.fn.expand '%:h'
        grug.open {
          transient = true,
          prefills = {
            paths = path,
          },
        }
      end,
      desc = 'Search/Replace in Directory',
    },

    -- ========================================================================
    -- SEARCH ALL FILES (NO FILTER)
    -- ========================================================================
    {
      '<leader>sR',
      function()
        local grug = require 'grug-far'
        grug.open {
          transient = true,
        }
      end,
      desc = 'Search/Replace (All Files)',
    },
  },
}

