local M = {}

M.get_run_cmd = function(langs)
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

return M
