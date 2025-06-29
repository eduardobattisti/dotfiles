vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', 'D', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', 'Dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<C-x>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<C-s>', '<cmd>:w<cr>', { desc = 'Save the current buffer' })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Paste without lose the copied value' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Paste without lose the copied value' })

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Keep cursor on middle of the screen when highlight' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Keep cursor on middle of the screen when highlight' })

-- vim.keymap.set('n', '<Leader>c', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Update all words under cursor on the file' })
vim.keymap.set('n', '<Leader>rn', '<cmd>set rnu!<CR>', { desc = 'Toggle relativenumber' })

-- Paste replace visual selection without copying it.
vim.keymap.set('v', 'p', '"_dP')

-- Folding
vim.keymap.set('n', '<leader>zs', function()
  vim.api.nvim_exec2('%foldc!', { output = false })
end, { desc = '[s]hut all folds' })

vim.keymap.set('n', '<leader>zo', function()
  vim.api.nvim_exec2('%foldo!', { output = false })
end, { desc = '[o]pen all folds' })
