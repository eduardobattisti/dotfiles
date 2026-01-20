-- ============================================================================
-- ENVIRONMENT DETECTION UTILITY
-- Detects whether running on work or personal machine
-- ============================================================================

local M = {}

-- Environment types
M.WORK = 'work'
M.PERSONAL = 'personal'

--- Get the current environment
--- Checks NVIM_ENV environment variable
--- Defaults to 'personal' if not set
---@return string 'work' | 'personal'
function M.get_env()
  local env = vim.env.NVIM_ENV or M.PERSONAL
  if env == M.WORK or env == M.PERSONAL then
    return env
  end
  return M.PERSONAL
end

--- Check if running in work environment
---@return boolean
function M.is_work()
  return M.get_env() == M.WORK
end

--- Check if running in personal environment
---@return boolean
function M.is_personal()
  return M.get_env() == M.PERSONAL
end

--- Get environment display name
---@return string
function M.get_display_name()
  local env = M.get_env()
  if env == M.WORK then
    return 'Work (Cursor CLI)'
  else
    return 'Personal (GitHub Copilot)'
  end
end

--- Show current environment notification
function M.notify_env()
  vim.notify('AI Environment: ' .. M.get_display_name(), vim.log.levels.INFO)
end

return M