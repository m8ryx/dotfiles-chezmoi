require("rrezinas.core")
require("rrezinas.lazy")
-- require("amazon_q.plugin")
-- Auto-reload files when they change (from Claude edits)
-- This is so that I can run claude code in one buffer and vim in another

vim.opt.autoread = true

vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
	pattern = "*",
	command = "checktime"
})

