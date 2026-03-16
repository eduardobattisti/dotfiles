-- ============================================================================
-- CORE EDITOR MAPPINGS
-- ============================================================================

-- Exit insert mode with jk
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Better search navigation (direction always consistent)
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next search result (centered)' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Previous search result (centered)' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Previous search result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Previous search result' })

-- Better vertical movement (wrapped lines)
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Enhanced scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down half page (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up half page (centered)' })

-- Undo breakpoints at punctuation (finer-grained undo)
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")
vim.keymap.set("i", "!", "!<c-g>u")
vim.keymap.set("i", "?", "?<c-g>u")

-- Save shortcuts
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>', { desc = 'Save current buffer' })
vim.keymap.set('i', '<C-s>', '<Esc><cmd>w<cr>a', { desc = 'Save in insert mode' })

-- Arrow key discipline (use hjkl instead)
vim.keymap.set('n', '<Up>', '<nop>', { desc = 'Use k instead' })
vim.keymap.set('n', '<Down>', '<nop>', { desc = 'Use j instead' })
vim.keymap.set('n', '<Left>', '<nop>', { desc = 'Use h instead' })
vim.keymap.set('n', '<Right>', '<nop>', { desc = 'Use l instead' })

-- ============================================================================
-- WINDOW AND BUFFER MANAGEMENT
-- ============================================================================

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move to right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move to upper window' })

-- Window resizing
vim.keymap.set('n', '<C-Left>', '<C-w><', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '<C-w>>', { desc = 'Increase window width' })
vim.keymap.set('n', '<C-Up>', '<C-w>+', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', '<C-w>-', { desc = 'Decrease window height' })

-- Window splits
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below" })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right" })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split [W]indow [V]ertically' })
vim.keymap.set('n', '<leader>wh', '<C-w>s', { desc = 'Split [W]indow [H]orizontally' })
vim.keymap.set('n', '<leader>we', '<C-w>=', { desc = '[W]indow [E]qual size' })
vim.keymap.set('n', '<leader>wc', function() require('utils.builtin').smart_close_window() end,
  { desc = '[W]indow [C]lose (smart)' })
vim.keymap.set('n', '<leader>wm', function() require('utils.builtin').toggle_maximize_window() end,
  { desc = '[W]indow [M]aximize toggle' })

-- Buffer navigation
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
vim.keymap.set('n', '<leader>`', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<cr>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>ba', function() require('utils.builtin').delete_other_buffers() end,
  { desc = '[B]uffer delete [A]ll except current' })

-- ============================================================================
-- DIAGNOSTICS (Enhanced with severity filtering)
-- ============================================================================

local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end

vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
vim.keymap.set('n', 'D', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic' })
vim.keymap.set('n', '<leader>dq', function() require('utils.builtin').diagnostics_to_quickfix() end,
  { desc = '[D]iagnostics to [Q]uickfix' })
vim.keymap.set('n', '<leader>dl', function() require('utils.builtin').diagnostics_to_loclist() end,
  { desc = '[D]iagnostics to [L]ocation list' })

-- ============================================================================
-- TAB MANAGEMENT
-- ============================================================================

vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- ============================================================================
-- FOLDING (UFO plugin integration)
-- ============================================================================

vim.keymap.set('n', '<leader>zf', 'zf', { desc = '[F]old create' })
vim.keymap.set('v', '<leader>zf', 'zf', { desc = '[F]old selection' })
vim.keymap.set('n', '<leader>zd', 'zd', { desc = '[D]elete fold' })
vim.keymap.set('n', '<leader>zp', function()
  local winid = require('ufo').peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end, { desc = '[P]eek fold or hover' })

-- ============================================================================
-- MARKS AND REGISTERS
-- ============================================================================

vim.keymap.set('n', '<leader>mm', function() require('utils.builtin').set_global_mark('A') end,
  { desc = '[M]ark set global A' })
vim.keymap.set('n', '<leader>ma', function() require('utils.builtin').jump_to_mark('A') end,
  { desc = 'Go to [M]ark [A]' })
vim.keymap.set('n', '<leader>ml', '<cmd>marks<cr>', { desc = '[M]arks [L]ist' })
vim.keymap.set('n', '<leader>r', '<cmd>registers<cr>', { desc = 'Show [R]egisters' })
vim.keymap.set('v', '<leader>ry', function() require('utils.builtin').copy_to_clipboard() end,
  { desc = '[R]egister [Y]ank to clipboard' })
vim.keymap.set('n', '<leader>rp', '"+p', { desc = '[R]egister [P]aste from clipboard' })

-- ============================================================================
-- TEXT EDITING ENHANCEMENTS
-- ============================================================================

-- Better paste behavior
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste without yanking' })

-- Line manipulation
vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Move line up' })
vim.keymap.set('i', '<A-j>', '<Esc><cmd>m .+1<cr>==gi', { desc = 'Move line down' })
vim.keymap.set('i', '<A-k>', '<Esc><cmd>m .-2<cr>==gi', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })

-- Indentation
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left (keep selection)' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right (keep selection)' })

-- ============================================================================
-- TERMINAL
-- ============================================================================

vim.keymap.set('t', '<C-x>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-h>', '<cmd>wincmd h<cr>', { desc = 'Terminal: move to left window' })
vim.keymap.set('t', '<C-j>', '<cmd>wincmd j<cr>', { desc = 'Terminal: move to lower window' })
vim.keymap.set('t', '<C-k>', '<cmd>wincmd k<cr>', { desc = 'Terminal: move to upper window' })
vim.keymap.set('t', '<C-l>', '<cmd>wincmd l<cr>', { desc = 'Terminal: move to right window' })

-- ============================================================================
-- COMMAND LINE ENHANCEMENTS
-- ============================================================================

vim.keymap.set('c', '<C-a>', '<Home>', { desc = 'Go to beginning of line' })
vim.keymap.set('c', '<C-e>', '<End>', { desc = 'Go to end of line' })
vim.keymap.set('c', '<C-p>', '<Up>', { desc = 'Previous command' })
vim.keymap.set('c', '<C-n>', '<Down>', { desc = 'Next command' })

-- ============================================================================
-- UTILITIES
-- ============================================================================

-- Better escape (clears search + stops snippets)
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  local ok, luasnip = pcall(require, "luasnip")
  if ok and luasnip.in_snippet() then
    luasnip.unlink_current()
  end
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Better redraw
vim.keymap.set("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" })

-- Formatting (tries conform.nvim, falls back to LSP)
vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = true, lsp_fallback = true })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format" })

-- Quit all
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Inspect utilities
vim.keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
vim.keymap.set("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })
