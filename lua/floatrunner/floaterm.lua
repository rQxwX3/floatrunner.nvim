local M = {}


M.is_valid_floaterm = function(floatstate)
	return vim.api.nvim_buf_is_valid(floatstate.buf) and
			vim.api.nvim_win_is_valid(floatstate.win)
end


M.run_in_floaterm = function(floatstate, command, cwd)
	cwd = cwd or vim.loop.cwd()

	if not vim.api.nvim_buf_is_valid(floatstate.buf) or vim.loop.cwd() ~= cwd then
		M.create_termbuf(floatstate)
		vim.fn.chansend(floatstate.chan, "clear\n")
	end

	local commands = vim.split(command, "&&", { trimempty = true })

	for i, cmd in ipairs(commands) do
		local trimmed = vim.trim(cmd)
		if trimmed ~= "" then commands[i] = trimmed end
	end

	vim.defer_fn(function()
		M.show_floaterm(floatstate)

		for _, cmd in ipairs(commands) do
			vim.fn.chansend(floatstate.chan, cmd .. "\n")
		end
	end, 80)
end


M.show_floaterm = function(floatstate)
	if M.is_valid_floaterm(floatstate) then return end

	if not vim.api.nvim_buf_is_valid(floatstate.buf) then
		M.create_termbuf(floatstate)
	end

	local height = math.floor(vim.o.lines * 0.8)
	local width = math.floor(vim.o.columns * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded"
	}

	floatstate.win = vim.api.nvim_open_win(
		floatstate.buf, true, win_config
	)

	vim.cmd("startinsert")
end


M.create_termbuf = function(floatstate, cwd)
	cwd = cwd or vim.loop.cwd()

	floatstate.buf = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(floatstate.buf, false, {
		relative = "editor",
		width = 1,
		height = 1,
		row = 0,
		col = 0,
		style = "minimal",
		border = "none"
	})

	vim.api.nvim_buf_call(floatstate.buf, function()
		floatstate.chan = vim.fn.termopen(os.getenv("SHELL") or "sh", { cwd = cwd })
	end)

	vim.api.nvim_win_close(win, true)
end

return M
