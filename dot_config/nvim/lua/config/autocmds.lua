-- ============================================================================
-- CORE EDITOR AUTOCOMMANDS
-- ============================================================================

-- Highlight yanked text
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = highlight_group,
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- ============================================================================
-- FILE AND BUFFER MANAGEMENT
-- ============================================================================

local file_group = vim.api.nvim_create_augroup('FileManagement', { clear = true })

-- Save explicitly: leaving a buffer must not write unfinished edits.

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  group = file_group,
  desc = 'Restore cursor position',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ============================================================================
-- TERMINAL ENHANCEMENTS
-- ============================================================================

local terminal_group = vim.api.nvim_create_augroup('Terminal', { clear = true })

-- Enter insert mode when entering terminal
vim.api.nvim_create_autocmd('TermOpen', {
  group = terminal_group,
  desc = 'Start terminal in insert mode',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd.startinsert()
  end,
})

-- ============================================================================
-- WEZTERM INTEGRATION
-- ============================================================================

-- WezTerm forwards <C-h/j/k/l> to Neovim only while this user var is "true"
-- (see wezterm/utils/keys.lua). A user var also works for WSL and SSH panes,
-- where WezTerm cannot read the foreground process name. Other terminals
-- ignore the sequence.
local wezterm_group = vim.api.nvim_create_augroup('WeztermUserVar', { clear = true })

local function set_is_nvim(value)
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  local encoded = value and vim.base64.encode(value) or ''
  io.stdout:write(('\x1b]1337;SetUserVar=IS_NVIM=%s\007'):format(encoded))
end

vim.api.nvim_create_autocmd({ 'VimEnter', 'VimResume' }, {
  group = wezterm_group,
  desc = 'Tell WezTerm that Neovim owns the pane',
  callback = function()
    set_is_nvim 'true'
  end,
})

vim.api.nvim_create_autocmd({ 'VimLeavePre', 'VimSuspend' }, {
  group = wezterm_group,
  desc = 'Hand pane navigation back to WezTerm',
  callback = function()
    set_is_nvim(nil)
  end,
})

-- ============================================================================
-- LSP AND DIAGNOSTICS
-- ============================================================================

local lsp_group = vim.api.nvim_create_augroup('LspEnhancements', { clear = true })

-- Auto-format on save for supported files
