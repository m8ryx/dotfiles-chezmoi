-- Amazon Q Neovim Plugin
local M = {}

-- Function to run Amazon Q and capture output
function M.run_amazon_q(prompt)
	-- Check if Amazon Q buffer already exists
	local amazon_q_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		if name:match("Amazon Q$") then
			amazon_q_buf = buf
			break
		end
	end
	
	local buf
	-- Create or reuse buffer for Amazon Q output
	if amazon_q_buf and vim.api.nvim_buf_is_valid(amazon_q_buf) then
		-- Reuse existing buffer
		vim.cmd('buffer ' .. amazon_q_buf)
		-- Clear the buffer content
		vim.api.nvim_buf_set_lines(amazon_q_buf, 0, -1, false, {})
		buf = amazon_q_buf
	else
		-- Create new buffer
		vim.cmd("new")
		buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_name(buf, "Amazon Q")
		
		-- Set buffer options
		vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
		vim.api.nvim_buf_set_option(buf, "swapfile", false)
		vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
	end

	-- Add initial message to buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Querying Amazon Q...", "", "Question: " .. prompt, "", "Response:"})

	-- Create a temporary file for the command output
	local output_file = "/tmp/amazon_q_output_" .. os.time() .. ".txt"
	
	-- Function to handle job completion
	local function on_exit(_, exit_code, _)
		if exit_code == 0 then
			-- Read the response from the output file
			local file = io.open(output_file, "r")
			if file then
				local content = file:read("*all")
				file:close()
				
				if content and content ~= "" then
					-- Process the content to extract the actual response
					local lines = {}
					for line in content:gmatch("[^\r\n]+") do
						-- Remove ANSI escape sequences
						line = line:gsub("\27%[[0-9;]*m", "")
						table.insert(lines, line)
					end
					
					-- Find where the actual response starts (after the separator line)
					local response_start = 0
					for i, line in ipairs(lines) do
						if line:match("━━━━") then
							response_start = i + 1
							break
						end
					end
					
					-- Extract the response
					local response_lines = {}
					if response_start > 0 and response_start <= #lines then
						for i = response_start, #lines do
							if lines[i] and lines[i] ~= "" then
								table.insert(response_lines, lines[i])
							end
						end
					else
						-- Fallback: take everything after the first few lines
						for i = 6, #lines do
							if lines[i] and lines[i] ~= "" then
								table.insert(response_lines, lines[i])
							end
						end
					end
					
					-- Update the buffer with the response
					vim.schedule(function()
						if #response_lines > 0 then
							vim.api.nvim_buf_set_lines(buf, 5, -1, false, response_lines)
						else
							vim.api.nvim_buf_set_lines(buf, 5, -1, false, {
								"No response content could be extracted.",
								"",
								"Debug info:",
								"Output file: " .. output_file,
								"File exists: " .. tostring(vim.fn.filereadable(output_file) == 1),
								"File size: " .. vim.fn.getfsize(output_file) .. " bytes",
								"Number of lines processed: " .. #lines
							})
						end
					end)
				else
					vim.schedule(function()
						vim.api.nvim_buf_set_lines(buf, 5, -1, false, {
							"No output received from Amazon Q.",
							"",
							"Debug info:",
							"Output file: " .. output_file,
							"File exists: " .. tostring(vim.fn.filereadable(output_file) == 1),
							"File size: " .. vim.fn.getfsize(output_file) .. " bytes"
						})
					end)
				end
			else
				vim.schedule(function()
					vim.api.nvim_buf_set_lines(buf, 5, -1, false, {"Error: Could not read output file: " .. output_file})
				end)
			end
		else
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf, 5, -1, false, {
					"Error: Amazon Q command failed with exit code " .. exit_code,
					"",
					"Debug info:",
					"Helper script: /home/rrezinas/amazon_q_helper.sh",
					"Output file: " .. output_file,
					"",
					"Try running this command directly in your terminal to see the error:",
					"/home/rrezinas/amazon_q_helper.sh \"" .. prompt:gsub('"', '\\"') .. "\" " .. output_file
				})
			end)
		end
	end

	-- Run the helper script to ensure we capture the output correctly
	local cmd = "/home/rrezinas/amazon_q_helper.sh \"" .. prompt:gsub('"', '\\"') .. "\" " .. output_file
	
	-- Use a job to run the command asynchronously
	vim.fn.jobstart(cmd, {
		on_exit = on_exit,
		shell = true
	})
end

-- Function to ask Amazon Q about selected text
function M.ask_about_selection()
	-- Get visual selection
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.fn.getline(start_pos[2], end_pos[2])

	-- Adjust the last line to consider only up to the column of end_pos
	if #lines > 0 then
		lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
		-- Adjust the first line to start from the column of start_pos
		lines[1] = string.sub(lines[1], start_pos[3], #lines[1])
	end

	local selected_text = table.concat(lines, "\n")

	-- Prompt for additional question
	local additional_question = vim.fn.input("Ask Amazon Q about this code: ")

	-- Combine selected text and question
	local prompt = "Here's the code:\n" .. selected_text .. "\n\n" .. additional_question

	-- Run Amazon Q with the prompt
	M.run_amazon_q(prompt)
end

-- Function to ask a direct question to Amazon Q
function M.ask_question()
	local question = vim.fn.input("Ask Amazon Q: ")
	if question and question ~= "" then
		M.run_amazon_q(question)
	end
end

return M
