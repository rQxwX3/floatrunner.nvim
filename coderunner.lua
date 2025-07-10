local state = {
	floating = {
		buf = -1,
		win = -1
	}
}

local function create_floating_window(opts)
	opts = opts or {}

	local height = opts.height or math.floor(vim.o.lines * 0.8)
	local width = opts.width or math.floor(vim.o.columns * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = nil

	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded"
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

local function run_command_in_terminal(commandstring)
	if not commandstring or commandstring == "" then
		vim.notify("Expected a non-empty command string", vim.log.levels.WARN)
		return
	end

	local commands = vim.split(commandstring, "&&", { trimempty = true })
	for i, cmd in ipairs(commands) do
		local trimmed = vim.trim(cmd)
		if trimmed ~= "" then
			commands[i] = trimmed
		end
	end

	if #commands == 0 then
		vim.notify("No valid commands to run", vim.log.levels.WARN)
		return
	end

	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window { buf = state.floating.buf }
		vim.cmd.term()
	end

	vim.cmd("startinsert")

	local job_id = vim.b.terminal_job_id

	if not job_id then
		vim.notify("Failed to get terminal_job_id", vim.log.levels.ERROR)
	end

	for _, cmd in ipairs(commands) do
		vim.fn.chansend(job_id, cmd .. "\n")
	end
end

local toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window { buf = state.floating.buf }
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.term()
		end
		vim.cmd("startinsert")
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

local compile_run_c = function()
	local cfile = vim.fn.expand("%:t")
	local objfile = vim.fn.expand("%:r")

	local cmdstring = string.format("gcc %s -o %s && ./%s", cfile, objfile, objfile)
	run_command_in_terminal(cmdstring)
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.api.nvim_create_user_command("FloaterminalRun", function(opts)
	run_command_in_terminal(opts.args)
end, {
	nargs = "+",
})
vim.keymap.set("n", "<leader>tt", toggle_terminal)
vim.keymap.set("t", "<esc><esc>", toggle_terminal)
vim.keymap.set("n", "<leader>cc", compile_run_c)
