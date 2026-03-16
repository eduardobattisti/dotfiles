-- ============================================================================
-- BUILT-IN FEATURE UTILITIES
-- ============================================================================

local M = {}

-- ============================================================================
-- QUICKFIX AND LOCATION LIST UTILITIES
-- ============================================================================

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

function M.delete_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end

-- ============================================================================
-- WINDOW UTILITIES
-- ============================================================================

function M.smart_close_window()
  local win_count = vim.fn.winnr('$')
  if win_count > 1 then
    vim.cmd("close")
  else
    print("Cannot close last window")
  end
end

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
-- DIAGNOSTIC UTILITIES
-- ============================================================================

function M.diagnostics_to_quickfix()
  vim.diagnostic.setqflist()
  vim.cmd('copen')
end

function M.diagnostics_to_loclist()
  vim.diagnostic.setloclist()
  vim.cmd('lopen')
end

-- ============================================================================
-- MARK UTILITIES
-- ============================================================================

function M.set_global_mark(mark)
  vim.cmd('mark ' .. mark:upper())
  print('Set global mark ' .. mark:upper())
end

function M.jump_to_mark(mark)
  vim.cmd('normal! `' .. mark:upper())
end

-- ============================================================================
-- REGISTER UTILITIES
-- ============================================================================

function M.copy_to_clipboard()
  vim.cmd('normal! "+y')
  print('Copied to system clipboard')
end

return M