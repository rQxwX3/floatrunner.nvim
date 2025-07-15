local M = {}

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

M.builds = {
	{
		filename = "Makefile",
		command = "make"
	}
}

M.maps = {
	floaterm_on = "<leader>tt",
	floaterm_off = "<esc><esc>",
	floatrun = "<leader>fr",
	floatbuild = "<leader>fb"
}

return M
