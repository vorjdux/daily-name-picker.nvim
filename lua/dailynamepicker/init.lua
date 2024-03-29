local M = {}

-- Global variables
M.names_list = {}
M.used_names = {}
M.last_picked_name = nil
M.buffer_id = nil
M.window_id = nil

M.default_bindings = {
	load_names_from_input = "<leader>dn",
	load_names_from_file = "<leader>df",
	pick_random_name = "<leader>dp",
	unpick_last_name = "<leader>du",
	close_popup = "<leader>dc",
}

-- Setup function to initialize commands and keybindings
function M.setup(opts)
	opts = opts or {}

	vim.cmd([[
    hi SelectedName guifg=Yellow guibg=None gui=bold
    hi UsedName guifg=Grey guibg=None gui=strikethrough
  ]])

	-- Creating user commands
	vim.api.nvim_create_user_command("DailyLoadNames", function()
		M.load_names_interactive()
	end, { desc = "Load names from a comma-separated string." })

	vim.api.nvim_create_user_command("DailyLoadNamesFromFile", function()
		M.load_names_from_file_interactive()
	end, { desc = "Load names from a file." })

	vim.api.nvim_create_user_command("DailyPickRandomName", function()
		M.pick_random_name()
	end, { desc = "Pick a random name from the list." })

	vim.api.nvim_create_user_command("DailyUnpickLastName", function()
		M.unpick_last_name()
	end, { desc = "Unpick the last picked name, making it available again." })

	vim.api.nvim_create_user_command("DailyDisplayNames", function()
		M.display_names()
	end, { desc = "Display the names in a full-screen overlay." })

	vim.api.nvim_create_user_command("DailyClosePopup", function()
		M.close_popup()
	end, { desc = "Close the names display popup." })

	-- Extending and applying custom bindings if provided
	local bindings = vim.tbl_extend("force", M.default_bindings, opts.bindings or {})

	-- Setting key mappings for commands
	for action, keys in pairs(bindings) do
		-- Transform action names from snake_case to CamelCase to match command names
		local commandName = action
			:gsub("(%l)(%w*)", function(a, b)
				return a:upper() .. b
			end)
			:gsub("_", "")
		-- Prepend 'Daily' to match the user command names
		local command = string.format(":Daily%s<CR>", commandName)
		if keys ~= "" then
			vim.api.nvim_set_keymap("n", keys, command, { noremap = true, silent = true })
		end
	end
end

-- Utility to check if the window is open
function M.is_window_open()
	return M.window_id and vim.api.nvim_win_is_valid(M.window_id)
end

-- Utility to open full-screen window
function M.open_full_screen_popup()
	if M.is_window_open() then
		return -- Do not open another window if one is already open
	end

	M.buffer_id = vim.api.nvim_create_buf(false, true)
	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	M.window_id = vim.api.nvim_open_win(M.buffer_id, true, {
		relative = "editor",
		width = width,
		height = height,
		col = 0,
		row = 0,
		style = "minimal",
		border = "none",
	})

	vim.api.nvim_win_set_option(M.window_id, "winblend", 20) -- Optional: make the window slightly transparent
end

-- Close the popup window
function M.close_popup()
	if M.is_window_open() then
		vim.api.nvim_win_close(M.window_id, true)
	end
end

function M.display_names()
	-- Ensure the buffer exists or create it
	if not M.buffer_id or not vim.api.nvim_buf_is_valid(M.buffer_id) then
		M.open_full_screen_popup()
	end

	vim.api.nvim_buf_set_option(M.buffer_id, "modifiable", true)
	vim.api.nvim_buf_set_lines(M.buffer_id, 0, -1, false, {})

	local empty_lines = { "", "", "", "" } -- Four empty lines for padding
	vim.api.nvim_buf_set_lines(M.buffer_id, 0, -1, false, empty_lines)

	local width = vim.api.nvim_win_get_width(M.window_id)

	for i, name in ipairs(M.names_list) do
		local padding = math.floor((width - string.len(name)) / 2)
		local line_content = string.rep(" ", padding) .. name
		vim.api.nvim_buf_set_lines(M.buffer_id, i + 3, i + 4, false, { line_content })

		-- Apply highlighting
		if name == M.last_picked_name then
			-- Highlight for the selected name
			vim.api.nvim_buf_add_highlight(M.buffer_id, -1, "SelectedName", i + 3, padding, padding + string.len(name))
		elseif vim.tbl_contains(M.used_names, name) then
			-- Highlight for used names
			vim.api.nvim_buf_add_highlight(M.buffer_id, -1, "UsedName", i + 3, padding, padding + string.len(name))
		end
	end

	vim.api.nvim_buf_set_option(M.buffer_id, "modifiable", false)

	-- Ensure the window is open and display the buffer
	if not M.is_window_open() then
		M.open_full_screen_popup()
	else
		-- If the window exists but for some reason, the buffer isn't displayed, set it again.
		vim.api.nvim_win_set_buf(M.window_id, M.buffer_id)
	end
end

-- Pick a random name
function M.pick_random_name()
	if #M.names_list == 0 then
		print("Names list is empty.")
		return
	end

	local unused_names = {}
	for _, name in ipairs(M.names_list) do
		if not vim.tbl_contains(M.used_names, name) then
			table.insert(unused_names, name)
		end
	end

	if #unused_names == 0 then
		print("All names have been used.")
		return
	end

	local picked_index = math.random(#unused_names)
	local picked_name = unused_names[picked_index]
	table.insert(M.used_names, picked_name)
	M.last_picked_name = picked_name
	M.display_names()
	print("Picked name: " .. picked_name)
end

function M.unpick_last_name()
	if M.last_picked_name then
		-- Find the last picked name in the used names list and remove it
		for i, name in ipairs(M.used_names) do
			if name == M.last_picked_name then
				table.remove(M.used_names, i)
				break -- Stop the loop once the name is found and removed
			end
		end

		-- Clear the last picked name
		M.last_picked_name = nil

		-- Optionally, refresh the names display if needed
		if M.is_window_open() then
			M.display_names()
		end

		print("Name unpicked and made available for picking again.")
	else
		print("No last picked name to unmark.")
	end
end

-- Load names from a string
function M.load_names_from_string(names_str)
	M.names_list = vim.split(names_str, ",", { trimempty = true })
	M.used_names = {}
	M.last_picked_name = nil
	print("Loaded names: ", vim.inspect(M.names_list))
end

-- Load names from a file
function M.load_names_from_file(file_path)
	local lines = {}
	for line in io.lines(file_path) do
		table.insert(lines, line)
	end
	M.names_list = lines
	M.used_names = {}
	M.last_picked_name = nil
	print("Loaded names from file: " .. file_path)
end

function M.load_names_interactive()
	local names = vim.fn.input("Enter names (comma-separated): ")
	M.load_names_from_string(names) -- Assuming this function processes the 'names' string
end

function M.load_names_from_file_interactive()
	-- Prompt the user to enter a file path with completion for files
	local file_path = vim.fn.input("Enter file path: ", "", "file")

	-- Expand the path to handle shortcuts like ~/
	file_path = vim.fn.expand(file_path)

	if file_path and #file_path > 0 then
		M.load_names_from_file(file_path)
	else
		print("Invalid file path.")
	end
end

return M
