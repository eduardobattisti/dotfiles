-- ============================================================================
-- CORE EDITOR AUTOCOMMANDS
-- ============================================================================

-- Highlight yanked text
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- ============================================================================
-- FILE AND BUFFER MANAGEMENT
-- ============================================================================

local file_group = vim.api.nvim_create_augroup('FileManagement', { clear = true })

-- Handle directory opening with netrw (replaces neo-tree auto-loading)
vim.api.nvim_create_autocmd('BufEnter', {
  group = file_group,
  desc = 'Open netrw when entering directory',
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == '' then return end
    
    local stats = (vim.uv or vim.loop).fs_stat(bufname)
    if stats and stats.type == 'directory' then
      vim.cmd.Explore()
    end
  end,
})

-- Auto-save when focus is lost
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
  group = file_group,
  desc = 'Auto-save when losing focus',
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
      vim.cmd.write()
    end
  end,
})

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
-- LSP AND DIAGNOSTICS
-- ============================================================================

local lsp_group = vim.api.nvim_create_augroup('LspEnhancements', { clear = true })

-- Auto-format on save for supported files
vim.api.nvim_create_autocmd('BufWritePre', {
  group = lsp_group,
  desc = 'Auto-format before save',
  callback = function()
    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      vim.lsp.buf.format({ async = false })
    end
  end,
})

-- Update diagnostics in quickfix list
vim.api.nvim_create_autocmd('DiagnosticChanged', {
  group = lsp_group,
  desc = 'Update quickfix with diagnostics',
  callback = function()
    vim.diagnostic.setqflist({ open = false })
  end,
})

-- ============================================================================
-- UI AND VISUAL ENHANCEMENTS
-- ============================================================================

local ui_group = vim.api.nvim_create_augroup('UIEnhancements', { clear = true })

-- Auto-resize windows on terminal resize
vim.api.nvim_create_autocmd('VimResized', {
  group = ui_group,
  desc = 'Auto-resize windows',
  callback = function()
    vim.cmd.wincmd('=')
  end,
})

-- Close certain filetypes with 'q'
vim.api.nvim_create_autocmd('FileType', {
  group = ui_group,
  pattern = { 'qf', 'help', 'man', 'lspinfo', 'checkhealth' },
  desc = 'Close with q',
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- Highlight current line number in focused window
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  group = ui_group,
  desc = 'Highlight current line number',
  callback = function()
    if vim.wo.number or vim.wo.relativenumber then
      vim.wo.cursorline = true
      vim.wo.cursorlineopt = 'number'
    end
  end,
})

vim.api.nvim_create_autocmd('WinLeave', {
  group = ui_group,
  desc = 'Remove line number highlight',
  callback = function()
    vim.wo.cursorline = false
  end,
})
