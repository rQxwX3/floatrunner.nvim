local backend = require "backend"


local M = {}


local state = {
	floaterm = {
		buf = -1,
		win = -1,
		chan = -1,
	}
}


local langs = {
	{
		ext = "c",
		command = "gcc %s -o %s && ./%s",
		argv = { "%.", "%", "%" }
	},
	{
		ext = "py",
		command = "python3 %s",
		argv = { "%." }
	},
}


M.setup = function()
	vim.keymap.set("n", "<leader>tt", M.toggle_floaterm)
	vim.keymap.set("t", "<esc><esc>", M.toggle_floaterm, {
		buffer = state.floaterm.buf
	})
	vim.keymap.set("n", "<leader>fr", M.floatrun)
end


M.toggle_floaterm = function()
	if not backend.is_valid_floaterm(state.floaterm) then
		state.floaterm = backend.create_floaterm(state.floaterm)
	else
		vim.api.nvim_win_hide(state.floaterm.win)
	end
end


M.floatrun = function()
	local cmdstring = backend.get_cmdstring(langs)

	if cmdstring then
		backend.run_in_floaterm(cmdstring, state.floaterm)
	else
		vim.notify("Unable to create cmdstring", vim.log.levels.WARN)
	end
end


return M
