-- ============================================================================
-- BUILT-IN FEATURE UTILITIES
-- Utility functions to enhance Neovim's built-in capabilities
-- ============================================================================

local M = {}

-- ============================================================================
-- QUICKFIX AND LOCATION LIST UTILITIES
-- ============================================================================

-- Toggle quickfix list
function M.toggle_quickfix()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end

-- Toggle location list
function M.toggle_loclist()
  local loc_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["loclist"] == 1 then
      loc_exists = true
    end
  end
  if loc_exists == true then
    vim.cmd("lclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getloclist(0)) then
    vim.cmd("lopen")
  end
end

-- ============================================================================
-- BUFFER UTILITIES
-- ============================================================================

-- Delete all buffers except current
function M.delete_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  
  for _, buf in ipairs(buffers) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end

-- Smart buffer deletion (handles special buffers)
function M.smart_delete_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  
  -- Special handling for certain filetypes
  if filetype == "netrw" then
    vim.cmd("bwipeout")
  elseif vim.bo[buf].modified then
    print("Buffer has unsaved changes")
  else
    vim.cmd("bdelete")
  end
end

-- ============================================================================
-- WINDOW UTILITIES
-- ============================================================================

-- Smart window close (handles last window)
function M.smart_close_window()
  local win_count = vim.fn.winnr('$')
  if win_count > 1 then
    vim.cmd("close")
  else
    print("Cannot close last window")
  end
end

-- Maximize current window toggle
function M.toggle_maximize_window()
  if vim.t.maximized then
    vim.cmd("wincmd =")
    vim.t.maximized = false
  else
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
    vim.t.maximized = true
  end
end

-- ============================================================================
-- TEXT EDITING UTILITIES
-- ============================================================================

-- Smart bracket/quote handling
function M.smart_backspace()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before = line:sub(col, col)
  local after = line:sub(col + 1, col + 1)
  
  local pairs = {
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['"'] = '"',
    ["'"] = "'"
  }
  
  if pairs[before] == after then
    return '<BS><Del>'
  else
    return '<BS>'
  end
end

-- Insert matching pair
function M.insert_pair(open, close)
  close = close or open
  return open .. close .. '<Left>'
end

-- ============================================================================
-- SEARCH AND REPLACE UTILITIES
-- ============================================================================

-- Search for word under cursor with boundaries
function M.search_word_under_cursor()
  local word = vim.fn.expand('<cword>')
  if word ~= '' then
    vim.fn.setreg('/', '\\<' .. word .. '\\>')
    vim.cmd('normal! n')
  end
end

-- Replace word under cursor
function M.replace_word_under_cursor()
  local word = vim.fn.expand('<cword>')
  return ':%s/\\<' .. word .. '\\>/<C-r><C-w>/gI<Left><Left><Left>'
end

-- ============================================================================
-- FILE AND DIRECTORY UTILITIES
-- ============================================================================

-- Create directory for current file if it doesn't exist
function M.create_dir_if_missing()
  local dir = vim.fn.expand('%:p:h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
    print('Created directory: ' .. dir)
  end
end

-- Open file explorer in current buffer's directory
function M.explore_current_dir()
  local dir = vim.fn.expand('%:p:h')
  vim.cmd('Explore ' .. dir)
end

-- ============================================================================
-- TERMINAL UTILITIES
-- ============================================================================

-- Smart terminal creation
function M.create_terminal(direction)
  local cmd = 'terminal'
  
  if direction == 'horizontal' then
    cmd = 'split | ' .. cmd
  elseif direction == 'vertical' then
    cmd = 'vsplit | ' .. cmd
  elseif direction == 'tab' then
    cmd = 'tabnew | ' .. cmd
  end
  
  vim.cmd(cmd)
  vim.cmd('startinsert')
end

-- ============================================================================
-- DIAGNOSTIC UTILITIES
-- ============================================================================

-- Send all diagnostics to quickfix
function M.diagnostics_to_quickfix()
  vim.diagnostic.setqflist()
  vim.cmd('copen')
end

-- Send buffer diagnostics to location list
function M.diagnostics_to_loclist()
  vim.diagnostic.setloclist()
  vim.cmd('lopen')
end

-- ============================================================================
-- FOLD UTILITIES
-- ============================================================================

-- Toggle fold under cursor
function M.toggle_fold()
  if vim.fn.foldclosed('.') == -1 then
    vim.cmd('foldclose')
  else
    vim.cmd('foldopen')
  end
end

-- ============================================================================
-- MARK UTILITIES
-- ============================================================================

-- Set global mark A-Z
function M.set_global_mark(mark)
  vim.cmd('mark ' .. mark:upper())
  print('Set global mark ' .. mark:upper())
end

-- Jump to global mark
function M.jump_to_mark(mark)
  vim.cmd('normal! `' .. mark:upper())
end

-- ============================================================================
-- REGISTER UTILITIES
-- ============================================================================

-- Show register contents in a neat format
function M.show_registers()
  local registers = vim.fn.getregister('"0123456789abcdefghijklmnopqrstuvwxyz*+')
  print(vim.inspect(registers))
end

-- Copy to system clipboard
function M.copy_to_clipboard()
  vim.cmd('normal! "+y')
  print('Copied to system clipboard')
end

-- ============================================================================
-- EXPORT MODULE
-- ============================================================================

return M