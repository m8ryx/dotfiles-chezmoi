require("rrezinas.core")
require("rrezinas.lazy")
-- Auto-reload files when they change (from Claude edits)
-- This is so that I can run claude code in one buffer and vim in another

vim.opt.autoread = true

vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
  pattern = "*",
  command = "checktime"
})

-- Flatpak to break out of the flatpak jail
--vim.o.shell = 'flatpak-spawn'
--vim.o.shellcmdflag = '--host bash -c'
--vim.o.shellxquote = ''


-- Single line: run current line through claude -p, replace with output
vim.keymap.set('n', '<leader>cp', function()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local result = vim.fn.system('claude -p ' .. vim.fn.shellescape(line))
--  local result = vim.fn.system('claude -p ' .. vim.fn.shellescape(line))

  -- Split into lines, remove trailing empty line
  local lines = vim.split(result, '\n', { trimempty = true })

  -- Replace current line with all output lines
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, lines)
end, { desc = 'Claude prompt: replace line with response' })

-- Visual selection version: replace selection with claude response
vim.keymap.set('v', '<leader>cp', function()
  -- Get selection
  vim.cmd('normal! gv"xy')
  local text = vim.fn.getreg('x')
  local result = vim.fn.system('claude -p ' .. vim.fn.shellescape(text))
  result = result:gsub('\n$', '')
  vim.fn.setreg('x', result)
  vim.cmd('normal! gv"xp')
end, { desc = 'Claude prompt: replace selection with response' })


