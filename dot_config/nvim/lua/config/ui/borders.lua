-- Enhanced floating window border configuration for Neovim
-- This module provides consistent border styling across all floating windows

local M = {}

-- Border styles
M.styles = {
  rounded = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
  thick = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
  double = { '╔', '═', '╗', '║', '╝', '═', '╚', '║' },
  single = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
  shadow = { '', '', '', '', '', '', '', '' },
  none = {},
}

-- Default border style
M.default_style = 'rounded'

-- Get border configuration
function M.get_border(style)
  style = style or M.default_style
  return M.styles[style] or M.styles[M.default_style]
end

-- Configure global floating window borders
function M.setup()
  -- Override vim.lsp.util.open_floating_preview to add borders
  local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or M.get_border()
    opts.max_width = opts.max_width or math.floor(vim.o.columns * 0.8)
    opts.max_height = opts.max_height or math.floor(vim.o.lines * 0.8)
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
  end

  -- Configure diagnostic floating windows
  vim.diagnostic.config({
    float = {
      border = M.get_border(),
      source = 'always',
      header = '',
      prefix = '',
      suffix = '',
      format = function(diagnostic)
        local code = diagnostic.code or diagnostic.user_data.lsp.code
        if code then
          return string.format('%s [%s]', diagnostic.message, code)
        end
        return diagnostic.message
      end,
    },
    virtual_text = {
      spacing = 4,
      source = 'if_many',
      prefix = '●',
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '',
        [vim.diagnostic.severity.WARN] = '',
        [vim.diagnostic.severity.INFO] = '',
        [vim.diagnostic.severity.HINT] = '',
      }
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Configure hover and signature help handlers
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = M.get_border(),
    silent = true,
    focusable = false,
  })

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = M.get_border(),
    silent = true,
    focusable = false,
  })

  -- Configure completion menu borders (if nvim-cmp is not handling it)
  vim.opt.pumblend = 10 -- Transparency for popup menu

  -- Set up autocmd to ensure consistent borders for any missed floating windows
  vim.api.nvim_create_autocmd('WinNew', {
    callback = function()
      local win = vim.api.nvim_get_current_win()
      local config = vim.api.nvim_win_get_config(win)
      
      -- Check if it's a floating window without borders
      if config.relative ~= '' and not config.border then
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            local new_config = vim.api.nvim_win_get_config(win)
            new_config.border = M.get_border()
            pcall(vim.api.nvim_win_set_config, win, new_config)
          end
        end)
      end
    end,
  })

  -- Highlight groups for borders
  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = function()
      -- Set border highlight groups
      vim.api.nvim_set_hl(0, 'FloatBorder', {
        fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg,
        bg = vim.api.nvim_get_hl(0, { name = 'NormalFloat' }).bg,
      })
      
      vim.api.nvim_set_hl(0, 'LspFloatWinBorder', {
        link = 'FloatBorder'
      })
      
      vim.api.nvim_set_hl(0, 'DiagnosticFloatingError', {
        link = 'DiagnosticError'
      })
      
      vim.api.nvim_set_hl(0, 'DiagnosticFloatingWarn', {
        link = 'DiagnosticWarn'
      })
      
      vim.api.nvim_set_hl(0, 'DiagnosticFloatingInfo', {
        link = 'DiagnosticInfo'
      })
      
      vim.api.nvim_set_hl(0, 'DiagnosticFloatingHint', {
        link = 'DiagnosticHint'
      })
    end,
  })

  -- Trigger initial highlight setup
  vim.schedule(function()
    vim.cmd('doautocmd ColorScheme')
  end)
end

-- Utility function to create bordered floating window
function M.create_floating_window(content, opts)
  opts = opts or {}
  
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  
  -- Calculate position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  
  local buf = vim.api.nvim_create_buf(false, true)
  
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    anchor = 'NW',
    style = 'minimal',
    border = opts.border or M.get_border(),
    title = opts.title,
    title_pos = opts.title_pos or 'center',
  }
  
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  if content then
    if type(content) == 'string' then
      content = vim.split(content, '\n')
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  end
  
  return buf, win
end

return M