local config_types = require "floatrunner.types.config-types"

local M = {}

---Finds and returns command to run the file
---@param langs LangConfig[]		--List of language configurations
---@return			string | nil					--Command to run
M.get_run_cmd = function(langs)
	if not langs then return nil end

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

	if not lang then return nil end

	local argv = vim.deepcopy(lang.argv)
	for i, arg in ipairs(argv) do
		if arg == "%" then argv[i] = vim.fn.expand("%:r") end
		if arg == "%." then argv[i] = vim.fn.expand("%") end
	end

	local cmdstring = nil

	if lang.command then
		local unpack = table.unpack or unpack
		cmdstring = string.format(lang.command, unpack(argv))
	end

	return cmdstring
end

return M
