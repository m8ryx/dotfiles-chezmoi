-- Amazon Q Plugin Setup
local amazon_q = require("amazon_q")
local completion = require("amazon_q.completion")

-- Create user commands
vim.api.nvim_create_user_command("AmazonQ", function()
	amazon_q.ask_question()
end, {})

vim.api.nvim_create_user_command("AmazonQSelection", function()
	amazon_q.ask_about_selection()
end, { range = true })

vim.api.nvim_create_user_command("AmazonQEnableCompletion", function()
	completion.setup_completion_source()
	print("Amazon Q completion enabled")
end, {})

-- Optional: Set up keymappings
-- Uncomment and modify these as needed
vim.api.nvim_set_keymap("n", "<leader>aq", ":AmazonQ<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>aq", ":AmazonQSelection<CR>", { noremap = true, silent = true })
