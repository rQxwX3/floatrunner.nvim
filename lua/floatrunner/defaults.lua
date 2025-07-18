local types = require "floatrunner.types.config-types"

---@type Options		Table of default configuration options
local M = {}

---@type LangConfig[]
M.langs = {
	{
		exts = { "c" },
		command = "gcc %s -o %s && ./%s",
		argv = { "%.", "%", "%" }
	},
	{
		exts = { "py" },
		command = "python3 %s",
		argv = { "%." }
	},
}

---@type BuildConfig[]
M.builds = {
	{
		filename = "Makefile",
		command = "make"
	}
}

---@type MapConfig
M.maps = {
	floaterm_on = "<leader>tt",
	floaterm_off = "<esc><esc>",
	floatrun = "<leader>fr",
	floatbuild = "<leader>fb"
}

return M
