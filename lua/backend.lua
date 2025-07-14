local M = {}

M.get_cmdstring = function(langs)
	local ext = vim.fn.expand("%:e")
	local lang = nil

	for _, l in ipairs(langs) do
		for _, e in ipairs(l.exts) do
			if e == ext then
				lang = l
				break
			end
		end
	end

	if not lang then
		local warnstring = string.format("No entry for ext: %s", ext)
		vim.notify(warnstring, vim.log.levels.WARN)
		return
	end

	local argv = vim.deepcopy(lang.argv)
	for i, arg in ipairs(argv) do
		if arg == "%" then argv[i] = vim.fn.expand("%:r") end
		if arg == "%." then argv[i] = vim.fn.expand("%") end
	end

	local cmdstring = ""

	if lang.command then
		local unpack = table.unpack or unpack
		cmdstring = string.format(lang.command, unpack(argv))
	else
		local warnstring = string.format("No command for ext: %s", ext)
		vim.notify(warnstring, vim.log.levels.WARN)
		return
	end

	return cmdstring
end


M.create_floatwin = function(floatstate)
	local height = math.floor(vim.o.lines * 0.8)
	local width = math.floor(vim.o.columns * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	if not vim.api.nvim_buf_is_valid(floatstate.buf) then
		floatstate.buf = vim.api.nvim_create_buf(false, true)
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

	floatstate.win = vim.api.nvim_open_win(
		floatstate.buf, true, win_config
	)

	return floatstate
end


M.create_floaterm = function(floatstate)
	floatstate = M.create_floatwin(floatstate)

	if vim.bo[floatstate.buf].buftype ~= "terminal" then
		vim.cmd.term()
	end

	vim.cmd("startinsert")

	return floatstate
end


M.is_valid_floaterm = function(floatstate)
	-- floaterm is valid = buf is valid, win is valid, buf is term
	return vim.api.nvim_buf_is_valid(floatstate.buf) and
			vim.api.nvim_win_is_valid(floatstate.win) and
			vim.bo[floatstate.buf].buftype == "terminal"
end


M.run_in_floaterm = function(cmdstring, floatstate)
	if not M.is_valid_floaterm(floatstate) then
		M.create_floaterm(floatstate)
	end

	vim.defer_fn(function()
		if floatstate.chan == -1 then
			floatstate.chan = vim.b.terminal_job_id
			vim.fn.chansend(floatstate.chan, "clear\n")
		end

		local commands = vim.split(cmdstring, "&&", { trimempty = true })

		for i, cmd in ipairs(commands) do
			local trimmed = vim.trim(cmd)
			if trimmed ~= "" then commands[i] = trimmed end
		end

		for _, cmd in ipairs(commands) do
			vim.fn.chansend(floatstate.chan, cmd .. "\n")
		end
	end, 100)
end

return M
