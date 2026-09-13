local M = {}

-- Use buffer bytes so unsaved edits and newly created files are included.
function M.is_large(bufnr, limit)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return true
  end
  local lines = vim.api.nvim_buf_line_count(bufnr)
  local bytes = vim.api.nvim_buf_get_offset(bufnr, lines)
  return vim.bo[bufnr].filetype == 'bigfile' or bytes > (limit or 1024 * 1024) or bytes / math.max(lines, 1) > 1000
end

return M
