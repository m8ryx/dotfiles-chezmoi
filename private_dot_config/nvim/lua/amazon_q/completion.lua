-- Amazon Q Code Completion
local M = {}

-- Store completion cache
M.completion_cache = {}

-- Function to get completion from Amazon Q
function M.get_completion(context, callback)
  -- Create a prompt for completion
  local prompt = "Complete this code snippet:\n\n" .. context
  
  -- Function to handle job output
  local output_data = {}
  local function on_output(_, data, _)
    if data then
      for _, line in ipairs(data) do
        if line and line ~= "" then
          table.insert(output_data, line)
        end
      end
    end
  end
  
  -- Function to handle job completion
  local function on_exit(_, exit_code, _)
    if exit_code == 0 and #output_data > 0 then
      -- Process completion results
      local completion_items = M.parse_completion_results(output_data)
      callback(completion_items)
    else
      callback({})
    end
  end
  
  -- Run Amazon Q CLI command for completion
  local cmd = {'q', 'chat', '--no-interactive', prompt}
  vim.fn.jobstart(cmd, {
    on_stdout = on_output,
    on_stderr = on_output,
    on_exit = on_exit,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

-- Parse completion results into completion items
function M.parse_completion_results(results)
  local completion_items = {}
  local in_code_block = false
  local current_completion = {}
  
  for _, line in ipairs(results) do
    -- Simple parsing logic - can be improved
    if line:match("^```") then
      in_code_block = not in_code_block
      if not in_code_block and #current_completion > 0 then
        -- End of code block, add as completion item
        table.insert(completion_items, {
          word = table.concat(current_completion, "\n"),
          kind = "Snippet",
          menu = "[Amazon Q]"
        })
        current_completion = {}
      end
    elseif in_code_block then
      table.insert(current_completion, line)
    end
  end
  
  return completion_items
end

-- Setup completion source for nvim-cmp
function M.setup_completion_source()
  local has_cmp, cmp = pcall(require, 'cmp')
  if not has_cmp then
    print("nvim-cmp not found. Code completion requires nvim-cmp.")
    return
  end
  
  local source = {}
  
  source.new = function()
    return setmetatable({}, { __index = source })
  end
  
  source.get_trigger_characters = function()
    return { '.', ':', '(', ',', ' ' }
  end
  
  source.get_keyword_pattern = function()
    return [[\k\+]]
  end
  
  source.complete = function(self, request, callback)
    local cursor_pos = request.context.cursor_pos
    local line = request.context.cursor_line
    local buf = request.context.bufnr
    
    -- Get context (previous N lines + current line up to cursor)
    local context_lines = 10
    local start_line = math.max(1, request.context.cursor.row - context_lines)
    local context = {}
    
    for i = start_line, request.context.cursor.row - 1 do
      table.insert(context, vim.api.nvim_buf_get_lines(buf, i-1, i, false)[1])
    end
    
    -- Add current line up to cursor
    table.insert(context, line:sub(1, cursor_pos[2]))
    
    local context_text = table.concat(context, "\n")
    
    -- Get file type for better context
    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
    if filetype and filetype ~= "" then
      context_text = "```" .. filetype .. "\n" .. context_text .. "\n```"
    end
    
    -- Get completion from Amazon Q
    M.get_completion(context_text, function(items)
      callback({
        items = items,
        isIncomplete = true
      })
    end)
  end
  
  -- Register the source with nvim-cmp
  cmp.register_source('amazon_q', source)
end

return M
