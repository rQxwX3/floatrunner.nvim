local state = {
	floaterm = {
		buf = -1,
		win = -1,
		chan = -1,
	}
}


local function is_valid_floaterm()
	-- floaterm is valid = buf is valid, win is valid, buf is term
	return vim.api.nvim_buf_is_valid(state.floaterm.buf) and
			vim.api.nvim_win_is_valid(state.floaterm.win) and
			vim.bo[state.floaterm.buf].buftype == "terminal"
end


local function create_floatwin(opts)
	opts = opts or {}

	local height = math.floor(vim.o.lines * 0.8)
	local width = math.floor(vim.o.columns * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	if vim.api.nvim_buf_is_valid(opts.buf) then
		state.floaterm.buf = opts.buf
	else
		state.floaterm.buf = vim.api.nvim_create_buf(false, true)
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

	state.floaterm.win = vim.api.nvim_open_win(
		state.floaterm.buf, true, win_config
	)
end


local function create_floaterm()
	create_floatwin { buf = state.floaterm.buf }

	if vim.bo[state.floaterm.buf].buftype ~= "terminal" then
		vim.cmd.term()
	end

	vim.cmd("startinsert")
end


local function toggle_floaterm()
	if not is_valid_floaterm() then
		create_floaterm()
	else
		vim.api.nvim_win_hide(state.floaterm.win)
	end
end


local function run_in_floaterm(cmdstring)
	if not is_valid_floaterm() then
		create_floaterm()
	end

	vim.defer_fn(function()
		if state.floaterm.chan == -1 then
			state.floaterm.chan = vim.b.terminal_job_id
			vim.fn.chansend(state.floaterm.chan, "clear\n")
		end

		local commands = vim.split(cmdstring, "&&", { trimempty = true })

		for i, cmd in ipairs(commands) do
			local trimmed = vim.trim(cmd)
			if trimmed ~= "" then commands[i] = trimmed end
		end

		for _, cmd in ipairs(commands) do
			vim.fn.chansend(state.floaterm.chan, cmd .. "\n")
		end
	end, 100)
end


local function compile_run_c()
	local cfile = vim.fn.expand("%:t")
	local objfile = vim.fn.expand("%:r")

	local cmdstring = string.format("gcc %s -o %s && ./%s", cfile, objfile, objfile)

	run_in_floaterm(cmdstring)
end


vim.keymap.set("n", "<leader>tt", toggle_floaterm)
vim.keymap.set("t", "<esc><esc>", toggle_floaterm)
vim.keymap.set("n", "<leader>cc", compile_run_c)
