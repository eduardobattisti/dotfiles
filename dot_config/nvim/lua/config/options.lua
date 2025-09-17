-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.tabstop = 2 -- Number of spaces tabs count for

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- Enhanced listchars for better indentation visualization (replaces indent-blankline)
vim.opt.list = true
vim.opt.listchars = { 
  tab = '» ', 
  trail = '·', 
  nbsp = '␣',
  extends = '❯',
  precedes = '❮',
  eol = '↲',
}
vim.opt.fillchars = {
  fold = '·',
  foldsep = '│',
  foldopen = '▼',
  foldclose = '▶',
  diff = '╱',
  eob = ' ',
}

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Enhanced built-in features configuration

-- Better netrw configuration (replaces file tree plugins for simple use)
vim.g.netrw_banner = 0 -- Disable banner
vim.g.netrw_liststyle = 3 -- Tree view
vim.g.netrw_browse_split = 0 -- Open files in same window
vim.g.netrw_altv = 1 -- Open splits to the right
vim.g.netrw_winsize = 25 -- Set width to 25%
vim.g.netrw_keepdir = 0 -- Keep current directory and browsing directory synced

-- Enhanced command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'
vim.opt.wildoptions = 'pum'

-- Better built-in completion
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.pumheight = 10 -- Limit popup menu height

-- Enhanced search configuration
vim.opt.gdefault = true -- Use global flag by default in substitute
vim.opt.magic = true -- Use magic patterns

-- Better backup and swap handling
vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup before overwriting
vim.opt.swapfile = false -- Disable swap files (rely on undofile)

-- Enhanced diff options
vim.opt.diffopt:append('linematch:60') -- Better diff algorithm

-- Better built-in terminal colors
vim.opt.termguicolors = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

vim.opt.wrap = false
vim.opt.relativenumber = true
vim.opt.whichwrap:append '<>[]hl'

-- Enhanced folding with UFO plugin
vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Load comprehensive border configuration
require('config.ui.borders').setup()


